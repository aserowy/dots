{
  application,
  namespace,
  charts,
  ...
}:
let
  homeassistant-cm = "homeassistant-cm";
  homeassistant-pvc = "homeassistant-pvc";
in
{
  applications."${application}" = {
    helm.releases = {
      postgresql = {
        chart = charts.bitnami.postgresql;
        values = {
          auth = {
            database = "homeassistant_db";
            username = "homeassistant";
            existingSecret = "postgresql";
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${homeassistant-pvc}
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
      ''
    ];

    resources = {
      configMaps = {
        homeassistant-cm = {
          metadata = {
            inherit namespace;
            name = homeassistant-cm;
          };
          data = {
            "configuration.yaml" = (builtins.readFile ./homeassistant.yaml);
          };
        };
      };

      statefulSets = {
        homeassistant = {
          apiVersion = "apps/v1";
          metadata = {
            inherit namespace;
            name = "homeassistant";
          };
          spec = {
            replicas = 1;
            selector.matchLabels.app = "homeassistant";
            template = {
              metadata.labels.app = "homeassistant";
              spec = {
                initContainers = [
                  {
                    name = "copy-base-config";
                    image = "mikefarah/yq:4.46.1"; # docker/mikefarah/yq@semver-coerced
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
                    image = "bash:5.3.0"; # docker/bash@semver-coerced
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
                    image = "ghcr.io/home-assistant/home-assistant:2025.7"; # github-release/home-assistant/core@semver-coerced
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
                        cpu = "200m";
                        memory = "500Mi";
                      };
                      limits = {
                        "akri.sh/akri-enocean-stick" = "1";
                        cpu = "1000m";
                        memory = "1000Mi";
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
                    name = "secrets";
                    secret.secretName = "homeassistant";
                  }
                ];
              };
            };
          };
        };
      };

      services = {
        homeassistant = {
          metadata = {
            inherit namespace;
            name = "homeassistant";
          };
          spec = {
            selector.app = "homeassistant";
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 8123;
              }
            ];
          };
        };
      };

      ingressRoutes = {
        homeassistant-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`homeassistanttest.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "homeassistant";
                  port = 8123;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
      };
    };
  };
}
