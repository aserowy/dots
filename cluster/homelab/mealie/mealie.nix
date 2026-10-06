{
  application,
  namespace,
  ...
}:
let
  dataPvc = "mealie-data-pvc";
in
{
  applications."${application}" = {
    resources = {
      clusters.mealie-pg17.spec = {
        instances = 2;
        imageCatalogRef = {
          apiGroup = "postgresql.cnpg.io";
          kind = "ClusterImageCatalog";
          name = "trixie";
          major = 17;
        };
        storage.size = "2Gi";

        bootstrap.initdb = {
          owner = "mealie";
          database = "mealie";
          secret.name = "mealie-pg";
        };

        resources.requests = {
          cpu = "150m";
          memory = "300Mi";
        };

        managed.services.disabledDefaultServices = [
          "ro"
          "r"
        ];
      };

      statefulSets.mealie = {
        apiVersion = "apps/v1";
        metadata = {
          inherit namespace;
          name = "mealie";
        };
        spec = {
          replicas = 1;
          serviceName = "mealie";
          selector.matchLabels."app.kubernetes.io/name" = "mealie";
          template = {
            metadata.labels = {
              "app.kubernetes.io/name" = "mealie";
              "app.kubernetes.io/component" = "app";
            };
            spec = {
              securityContext.seccompProfile.type = "RuntimeDefault";
              initContainers = [
                {
                  name = "await-db-init";
                  image = "busybox:1.38.0"; # docker/busybox@semver-coerced
                  command = [
                    "sh"
                    "-c"
                    "until nc -z mealie-pg17-rw 5432; do echo 'waiting for postgresql.'; sleep 5; done"
                  ];
                }
              ];
              containers = [
                {
                  name = "mealie";
                  image = "ghcr.io/mealie-recipes/mealie:v3.28.0"; # docker/ghcr.io/mealie-recipes/mealie@semver-coerced
                  securityContext.allowPrivilegeEscalation = false;
                  env = [
                    {
                      name = "ALLOW_SIGNUP";
                      value = "false";
                    }
                    {
                      name = "BASE_URL";
                      value = "https://mealie.anderwerse.de";
                    }
                    {
                      name = "DB_ENGINE";
                      value = "postgres";
                    }
                    {
                      name = "PGID";
                      value = "911";
                    }
                    {
                      name = "POSTGRES_DB";
                      value = "mealie";
                    }
                    {
                      name = "POSTGRES_PASSWORD";
                      valueFrom.secretKeyRef = {
                        name = "mealie-pg";
                        key = "password";
                      };
                    }
                    {
                      name = "POSTGRES_PORT";
                      value = "5432";
                    }
                    {
                      name = "POSTGRES_SERVER";
                      value = "mealie-pg17-rw.mealie.svc.cluster.local";
                    }
                    {
                      name = "POSTGRES_USER";
                      valueFrom.secretKeyRef = {
                        name = "mealie-pg";
                        key = "username";
                      };
                    }
                    {
                      name = "PUID";
                      value = "911";
                    }
                    {
                      name = "TZ";
                      value = "Europe/Berlin";
                    }
                  ];
                  ports = [
                    {
                      name = "http";
                      containerPort = 9000;
                      protocol = "TCP";
                    }
                  ];
                  resources = {
                    requests = {
                      cpu = "100m";
                      memory = "512Mi";
                    };
                    limits.memory = "1Gi";
                  };
                  startupProbe = {
                    httpGet = {
                      path = "/api/app/about";
                      port = 9000;
                    };
                    periodSeconds = 10;
                    failureThreshold = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/api/app/about";
                      port = 9000;
                    };
                    periodSeconds = 30;
                  };
                  readinessProbe.httpGet = {
                    path = "/api/app/about";
                    port = 9000;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/app/data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = dataPvc;
                }
              ];
            };
          };
        };
      };

      services.mealie = {
        metadata = {
          inherit namespace;
          name = "mealie";
        };
        spec = {
          selector."app.kubernetes.io/name" = "mealie";
          ports = [
            {
              name = "http";
              protocol = "TCP";
              port = 9000;
            }
          ];
        };
      };

      ingresses.mealie = {
        metadata = {
          inherit namespace;
          annotations."cert-manager.io/cluster-issuer" = "azure-acme-issuer";
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "mealie.anderwerse.de" ];
              secretName = "mealie-tls";
            }
          ];
          rules = [
            {
              host = "mealie.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "mealie";
                    port.number = 9000;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies = {
        mealie = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = { inherit namespace; };
          spec = {
            endpointSelector.matchLabels."app.kubernetes.io/name" = "mealie";
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
                        port = "9000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [
              {
                toEntities = [ "world" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "80";
                        protocol = "TCP";
                      }
                      {
                        port = "443";
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
                      {
                        port = "53";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                toEndpoints = [
                  {
                    matchLabels."app.kubernetes.io/name" = "postgresql";
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

        mealie-pg = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = { inherit namespace; };
          spec = {
            endpointSelector.matchLabels."app.kubernetes.io/name" = "postgresql";
            ingress = [
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
                    matchLabels."app.kubernetes.io/name" = "postgresql";
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
                    matchLabels."app.kubernetes.io/name" = "mealie";
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
                      {
                        port = "53";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                toEndpoints = [
                  {
                    matchLabels."app.kubernetes.io/name" = "postgresql";
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

    yamls = [
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${dataPvc}
        spec:
          storageClassName: "longhorn"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 5Gi
      ''
    ];
  };
}
