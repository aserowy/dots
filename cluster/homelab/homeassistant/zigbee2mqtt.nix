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
        zigbee2mqtt-cm = {
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
                  fsGroup = 1000;
                  runAsGroup = 1000;
                  runAsUser = 1000;
                  runAsNonRoot = true;

                  # NOTE: user group 27 will grant access to the given device
                  # $ ls -la /dev/ttyUSB0
                  # crw-rw---- 1 root dialout 188, 0 Jul  3 08:21 /dev/ttyUSB0
                  # $ getent group dialout
                  # dialout:x:27:
                  supplementalGroups = [ 27 ];
                };
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
                          echo "Configuration.yaml does not exists, creating one from config map /app/data/configmap-configuration.yaml"
                          echo "Uncommenting version"
                          sed 's/\# version:/version:/' /tmp/configmap-configuration.yaml > configuration.yaml
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
                        drop = [ "ALL" ];
                        add = [
                          "SYS_RAWIO"
                        ];
                      };
                    };
                    startupProbe = {
                      httpGet = {
                        path = "/";
                        port = 8080;
                      };
                      initialDelaySeconds = 30;
                      failureThreshold = 15;
                    };
                    livenessProbe = {
                      httpGet = {
                        path = "/";
                        port = 8080;
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
              match = "Host(`zigbeetest.anderwerse.de`)";
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
