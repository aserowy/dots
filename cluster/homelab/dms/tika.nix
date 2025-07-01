{ application, namespace, ... }:
{
  applications."${application}" = {
    resources = {
      deployments = {
        tika = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            inherit namespace;
            name = "tika";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "tika";
              };
            };
            strategy = {
              type = "RollingUpdate";
            };
            template = {
              metadata = {
                labels = {
                  app = "tika";
                };
              };
              spec = {
                securityContext = {
                  seccompProfile = {
                    type = "RuntimeDefault";
                  };
                };
                containers = [
                  {
                    name = "tika";
                    image = "docker.io/apache/tika:3.2.0.0"; # docker/apache/tika@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    ports = [
                      {
                        name = "http";
                        containerPort = 9998;
                        protocol = "TCP";
                      }
                    ];
                    resources = {
                      requests = {
                        cpu = "100m";
                        memory = "128Mi";
                      };
                      limits = {
                        cpu = "1000m";
                        memory = "1Gi";
                      };
                    };
                    volumeMounts = [
                      {
                        name = "tmp";
                        mountPath = "/tmp";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "tmp";
                    emptyDir.sizeLimit = "1Gi";
                  }
                ];
              };
            };
          };
        };
      };

      services = {
        tika = {
          metadata = {
            inherit namespace;
            name = "tika";
          };
          spec = {
            selector = {
              app = "tika";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 9998;
              }
            ];
          };
        };
      };
    };
  };
}
