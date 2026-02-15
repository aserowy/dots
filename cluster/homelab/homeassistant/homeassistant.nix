{
  application,
  namespace,
  ...
}:
let
  homeassistant-cm = "homeassistant-cm";
  homeassistant-pvc = "homeassistant-pvc";
in
{
  applications."${application}" = {
    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${homeassistant-pvc}
        spec:
          storageClassName: "longhorn"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
      ''
    ];

    resources = {
      clusters.homeassistant-pg17 = {
        spec = {
          instances = 2;
          imageCatalogRef = {
            apiGroup = "postgresql.cnpg.io";
            kind = "ClusterImageCatalog";
            name = "trixie";
            major = 17;
          };
          storage.size = "8Gi";

          bootstrap.initdb = {
            owner = "homeassistant";
            database = "homeassistant_db";
            secret.name = "homeassistant-pg";
          };

          resources.requests = {
            cpu = "300m";
            memory = "500Mi";
          };

          managed.services.disabledDefaultServices = [
            "ro"
            "r"
          ];
        };
      };

      configMaps.homeassistant-cm = {
        metadata = {
          inherit namespace;
          name = homeassistant-cm;
        };
        data = {
          "configuration.yaml" = (builtins.readFile ./homeassistant.yaml);
        };
      };

      statefulSets.homeassistant = {
        apiVersion = "apps/v1";
        metadata = {
          inherit namespace;
          name = "homeassistant";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "homeassistant";
          template = {
            metadata.labels = {
              "app.kubernetes.io/name" = "homeassistant";
              "app.kubernetes.io/component" = "app";
            };
            spec = {
              initContainers = [
                {
                  name = "copy-base-config";
                  image = "mikefarah/yq:4.52.4"; # docker/mikefarah/yq@semver-coerced
                  securityContext = {
                    allowPrivilegeEscalation = false;
                    readOnlyRootFilesystem = true;
                    capabilities = {
                      drop = [ "ALL" ];
                    };
                  };
                  workingDir = "/config";
                  command = [
                    "/bin/sh"
                    "-c"
                    ''
                      echo "create statics if not exist: automations.yaml, scenes.yaml, and scripts.yaml"
                      if [ ! -d "/config/themes" ]; then
                          mkdir ./themes
                      fi

                      if [ ! -f automations.yaml ]; then
                          touch automations.yaml
                      fi
                      if [ ! -f scenes.yaml ]; then
                          touch scenes.yaml
                      fi
                      if [ ! -f scripts.yaml ]; then
                          touch scripts.yaml
                      fi

                      cp --force /tmp/secrets.yaml secrets.yaml
                      cp --force /tmp/google_maps_location_sharing_cookies .google_maps_location_sharing.cookies.an_der_werse_4_gmail_com

                      if [ -f configuration.yaml ]
                      then
                        echo "Backing up existing configuration file to configuration-helm-backup.yaml"
                        cp --force configuration.yaml configuration-helm-backup.yaml
                      else
                        echo "configuration.yaml does not exists, creating one from config map configmap-configuration.yaml"
                        cp /tmp/configmap-configuration.yaml configuration.yaml
                      fi

                      echo "Replace existing values with config-map entries"
                      yq eval-all  '. as $item ireduce ({}; . * $item )' configuration.yaml /tmp/configmap-configuration.yaml > configuration.temp

                      echo "Move temp configuration and replace configuration.yaml"
                      mv --force configuration.temp configuration.yaml
                    ''
                  ];
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/config";
                    }
                    {
                      name = "config";
                      subPath = "configuration.yaml";
                      mountPath = "/tmp/configmap-configuration.yaml";
                    }
                    {
                      name = "secrets";
                      subPath = "google_maps_location_sharing_cookies";
                      mountPath = "/tmp/google_maps_location_sharing_cookies";
                    }
                    {
                      name = "secrets";
                      subPath = "secrets.yaml";
                      mountPath = "/tmp/secrets.yaml";
                    }
                  ];
                }
                {
                  name = "setup-hacs";
                  image = "bash:5.3.9"; # docker/bash@semver-coerced
                  securityContext = {
                    allowPrivilegeEscalation = false;
                    readOnlyRootFilesystem = true;
                    capabilities = {
                      drop = [ "ALL" ];
                    };
                  };
                  workingDir = "/config";
                  command = [
                    "bash"
                    "-c"
                    ''
                      echo "Check if HACS is already installed"
                      if [ ! -d "/config/custom_components/hacs" ]; then
                        echo "Installing HACS"
                        wget -O - https://get.hacs.xyz | bash -
                      fi
                    ''
                  ];
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/config";
                    }
                  ];
                }
              ];
              containers = [
                {
                  name = "homeassistant";
                  image = "homeassistant/home-assistant:2026.2.2"; # docker/homeassistant/home-assistant@semver-coerced
                  securityContext = {
                    allowPrivilegeEscalation = false;
                    capabilities = {
                      drop = [ "ALL" ];
                    };
                  };
                  env = [
                    {
                      name = "TZ";
                      value = "Europe/Berlin";
                    }
                  ];
                  startupProbe = {
                    httpGet = {
                      path = "/";
                      port = 8123;
                    };
                    initialDelaySeconds = 30;
                    failureThreshold = 15;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/";
                      port = 8123;
                    };
                  };
                  ports = [ { containerPort = 8123; } ];
                  resources = {
                    requests = {
                      "akri.sh/akri-enocean-stick" = "1";
                      cpu = "300m";
                      memory = "1000Mi";
                    };
                    limits = {
                      "akri.sh/akri-enocean-stick" = "1";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/config";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = homeassistant-pvc;
                }
                {
                  name = "config";
                  configMap.name = homeassistant-cm;
                }
                {
                  name = "dbus-socket";
                  emptyDir = { };
                }
                {
                  name = "secrets";
                  secret.secretName = "homeassistant";
                }
              ];
            };
          };
        };
      };

      services.homeassistant = {
        metadata = {
          inherit namespace;
          name = "homeassistant";
        };
        spec = {
          selector."app.kubernetes.io/name" = "homeassistant";
          ports = [
            {
              name = "http";
              protocol = "TCP";
              port = 8123;
            }
          ];
        };
      };

      ingresses.homeassistant = {
        metadata = {
          inherit namespace;
          annotations = {
            "cert-manager.io/cluster-issuer" = "azure-acme-issuer";
          };
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "homeassistant.anderwerse.de" ];
              secretName = "homeassistant-tls";
            }
          ];
          rules = [
            {
              host = "homeassistant.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "homeassistant";
                    port.number = 8123;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies = {
        homeassistant = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector = {
              matchLabels = {
                "app.kubernetes.io/name" = "homeassistant";
              };
            };
            ingress = [
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "io.kubernetes.pod.namespace" = "haproxy";
                      "app.kubernetes.io/name" = "kubernetes-ingress";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8123";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [
              { toEntities = [ "world" ]; }
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "io.kubernetes.pod.namespace" = "kube-system";
                      "k8s-app" = "kube-dns";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "53";
                        protocol = "UDP";
                      }
                    ];
                  }
                ];
              }
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "mosquitto";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "1883";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "postgresql";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "5432";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
          };
        };

        homeassistant-pg = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "postgresql";
            };
            ingress = [
              # NOTE: combining fromEndpoints and fromEntities is not supported
              {
                fromEntities = [ "host" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "io.kubernetes.pod.namespace" = "cnpg-system";
                      "app.kubernetes.io/name" = "cloudnative-pg";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "postgresql";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "5432";
                        protocol = "TCP";
                      }
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "homeassistant";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "5432";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [
              {
                toEntities = [ "kube-apiserver" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "6443";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "io.kubernetes.pod.namespace" = "kube-system";
                      "k8s-app" = "kube-dns";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "53";
                        protocol = "UDP";
                      }
                    ];
                  }
                ];
              }
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "postgresql";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "5432";
                        protocol = "TCP";
                      }
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
