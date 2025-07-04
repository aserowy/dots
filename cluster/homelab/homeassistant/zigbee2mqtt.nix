{
  application,
  namespace,
  ...
}:
let
  zigbee2mqtt-cm = "zigbee2mqtt-cm";
  zigbee2mqtt-pvc = "zigbee2mqtt-pvc";
in
{
  applications."${application}" = {
    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${zigbee2mqtt-pvc}
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
        adguard-cm = {
          metadata = {
            inherit namespace;
            name = zigbee2mqtt-cm;
          };
          data = {
            "configuration.yaml" = (builtins.readFile ./zigbee2mqtt.yaml);
          };
        };
      };

      statefulSets = {
        zigbee2mqtt = {
          apiVersion = "apps/v1";
          metadata = {
            inherit namespace;
            name = "zigbee2mqtt";
          };
          spec = {
            replicas = 1;
            selector.matchLabels.app = "zigbee2mqtt";
            template = {
              metadata.labels.app = "zigbee2mqtt";
              spec = {
                securityContext = {
                  fsGroup = 1099;
                  runAsGroup = 1099;
                  runAsUser = 1099;
                  seccompProfile.type = "RuntimeDefault";
                };
                initContainers = [
                  {
                    name = "copy-base-config";
                    image = "mikefarah/yq:4.45.4"; # docker/mikefarah/yq@semver-coerced
                    workingDir = "/app/data";
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
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                      capabilities = {
                        drop = [ "ALL" ];
                      };
                    };
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
                        subPath = "secret.yaml";
                        mountPath = "/tmp/secret.yaml";
                      }
                    ];
                  }
                ];
                containers = [
                  {
                    name = "zigbee2mqtt";
                    image = "docker.io/koenkk/zigbee2mqtt:2.5.1"; # docker/koenkk/zigbee2mqtt@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                      capabilities = {
                        add = [ "SYS_ADMIN" ];
                      };
                    };
                    ports = [ { containerPort = 8080; } ];
                    resources = {
                      requests = {
                        "akri.sh/akri-zigbee-stick" = "1";
                        cpu = "200m";
                        memory = "600Mi";
                      };
                      limits = {
                        "akri.sh/akri-zigbee-stick" = "1";
                        cpu = "200m";
                        memory = "600Mi";
                      };
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
                    persistentVolumeClaim.claimName = zigbee2mqtt-pvc;
                  }
                  {
                    name = "config";
                    configMap.name = zigbee2mqtt-cm;
                  }
                  {
                    name = "secrets";
                    secret.secretName = "zigbee2mqtt";
                  }
                ];
              };
            };
          };
        };
      };

      services = {
        zigbee2mqtt = {
          metadata = {
            inherit namespace;
            name = "zigbee2mqtt";
          };
          spec = {
            selector.app = "zigbee2mqtt";
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 8080;
              }
            ];
          };
        };
      };

      ingressRoutes = {
        zigbee2mqtt-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`mqtt.test.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "zigbee2mqtt";
                  port = 8080;
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
