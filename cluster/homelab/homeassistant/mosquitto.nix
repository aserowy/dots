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
            name = mosquitto-cm;
          };
          data = {
            "mosquitto.conf" = (builtins.readFile ./mosquitto.conf);
          };
        };
      };

      deployments = {
        mosquitto = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            inherit namespace;
            name = "mosquitto";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "mosquitto";
              };
            };
            strategy = {
              type = "Recreate";
            };
            template = {
              metadata = {
                labels = {
                  app = "mosquitto";
                };
              };
              spec = {
                securityContext = {
                  fsGroup = "1099";
                  runAsGroup = "1099";
                  runAsUser = "1099";
                  seccompProfile = {
                    type = "RuntimeDefault";
                  };
                };
                containers = [
                  {
                    name = "mosquitto";
                    image = "docker.io/eclipse-mosquitto:2.0.21"; # docker/eclipse-mosquitto@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    ports = [
                      {
                        containerPort = 1883;
                      }
                    ];
                    resources = {
                      requests = {
                        cpu = "100m";
                        memory = "128Mi";
                      };
                      limits = {
                        cpu = "500m";
                        memory = "1Gi";
                      };
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
            selector = {
              app = "mosquitto";
            };
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
    };
  };
}
