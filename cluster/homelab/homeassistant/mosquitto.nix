{
  application,
  namespace,
  ...
}:
let
  mosquitto-cm = "mosquitto-config";
  mosquitto-pvc = "mosquitto-pvc";
in
{
  applications."${application}" = {
    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${mosquitto-pvc}
        spec:
          storageClassName: "longhorn-nobackup"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
      ''
    ];

    resources = {
      configMaps.mosquitto-cm = {
        metadata = {
          inherit namespace;
          name = mosquitto-cm;
        };
        data."mosquitto.conf" = (builtins.readFile ./mosquitto.conf);
      };

      statefulSets = {
        mosquitto = {
          apiVersion = "apps/v1";
          metadata = {
            inherit namespace;
            name = "mosquitto";
          };
          spec = {
            replicas = 1;
            selector.matchLabels."app.kubernetes.io/name" = "mosquitto";
            template = {
              metadata.labels."app.kubernetes.io/name" = "mosquitto";
              spec = {
                securityContext = {
                  fsGroup = 1099;
                  runAsGroup = 1099;
                  runAsUser = 1099;
                  seccompProfile.type = "RuntimeDefault";
                };
                containers = [
                  {
                    name = "mosquitto";
                    image = "docker.io/eclipse-mosquitto:2.0.22"; # docker/eclipse-mosquitto@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    ports = [ { containerPort = 1883; } ];
                    resources.requests = {
                      cpu = "10m";
                      memory = "20Mi";
                    };
                    volumeMounts = [
                      {
                        name = "data";
                        mountPath = "/mosquitto/data";
                      }
                      {
                        name = "config";
                        subPath = "mosquitto.conf";
                        mountPath = "/mosquitto/config/mosquitto.conf";
                      }
                      {
                        name = "password";
                        subPath = "password.txt";
                        mountPath = "/mosquitto/config/password.txt";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "data";
                    persistentVolumeClaim.claimName = mosquitto-pvc;
                  }
                  {
                    name = "config";
                    configMap.name = mosquitto-cm;
                  }
                  {
                    name = "password";
                    secret.secretName = "mosquitto";
                  }
                ];
              };
            };
          };
        };
      };

      services = {
        mosquitto = {
          metadata = {
            inherit namespace;
            name = "mosquitto";
          };
          spec = {
            selector."app.kubernetes.io/name" = "mosquitto";
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 1883;
              }
            ];
          };
        };
      };

      ciliumNetworkPolicies = {
        mosquitto = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector = {
              matchLabels = {
                "app.kubernetes.io/name" = "mosquitto";
              };
            };
            ingress = [
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
                        port = "1883";
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
                      "app.kubernetes.io/name" = "zigbee2mqtt";
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
            ];
            egress = [ { } ];
          };
        };
      };
    };
  };
}
