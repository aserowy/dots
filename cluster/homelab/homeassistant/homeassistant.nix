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
                securityContext = {
                  fsGroup = 1000;
                  runAsGroup = 1000;
                  runAsUser = 1000;
                  runAsNonRoot = true;
                };
                initContainers = [
                  {
                    name = "copy-base-config";
                    image = "mikefarah/yq:4.45.4"; # docker/mikefarah/yq@semver-coerced
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
                        cp --force /tmp/secret.yaml secret.yaml

                        if [ -f configuration.yaml ]
                        then
                          echo "Backing up existing configuration file to /app/data/configuration-helm-backup.yaml"
                          cp --force configuration.yaml configuration-helm-backup.yaml
                        else
                          echo "configuration.yaml does not exists, creating one from config map /app/data/configmap-configuration.yaml"
                          cp /tmp/configmap-configuration.yaml configuration.yaml
                        fi

                        yq --inplace '. *= load("/tmp/configmap-configuration.yaml") | del(.version) ' configuration.yaml
                        yq eval-all  '. as $item ireduce ({}; . * $item )' /tmp/configmap-configuration.yaml configuration.yaml > configuration.yaml
                      ''
                    ];
                    volumeMounts = [
                      {
                        name = "data";
                        mountPath = "/app/data";
                      }
                      {
                        name = "config";
                        subPath = "configuration.yaml";
                        mountPath = "/tmp/configmap-configuration.yaml";
                      }
                      {
                        name = "secrets";
                        subPath = "secrets.yaml";
                        mountPath = "/tmp/secrets.yaml";
                      }
                    ];
                  }
                ];
                containers = [
                  {
                    name = "homeassistant";
                    image = "docker.io/home-assistant/home-assistant:2025.7"; # docker/home-assistant/home-assistant@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                      capabilities = {
                        drop = [ "ALL" ];
                      };
                    };
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
                        cpu = "200m";
                        memory = "500Mi";
                      };
                      limits = {
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
