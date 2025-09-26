{ application, namespace, ... }:
{
  applications."${application}" = {
    resources = {
      deployments = {
        gotenberg = {
          apiVersion = "apps/v1";
          metadata = {
            inherit namespace;
            name = "gotenberg";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "gotenberg";
              };
            };
            strategy = {
              type = "RollingUpdate";
            };
            template = {
              metadata = {
                labels = {
                  app = "gotenberg";
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
                    name = "gotenberg";
                    image = "docker.io/gotenberg/gotenberg:8.23.2"; # docker/gotenberg/gotenberg@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    env = [
                      {
                        name = "CHROMIUM_DISABLE_JAVASCRIPT";
                        value = "true";
                      }
                      {
                        name = "CHROMIUM_ALLOW_LIST";
                        value = "file:///tmp/.*";
                      }
                    ];
                    ports = [
                      {
                        name = "http";
                        containerPort = 3000;
                        protocol = "TCP";
                      }
                    ];
                    resources = {
                      requests = {
                        cpu = "200m";
                        memory = "512Mi";
                      };
                      limits = {
                        cpu = "1000m";
                        memory = "512Mi";
                      };
                    };
                    volumeMounts = [
                      {
                        name = "home";
                        mountPath = "/home/gotenberg";
                      }
                      {
                        name = "tmp";
                        mountPath = "/tmp";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "home";
                    emptyDir.sizeLimit = "500Mi";
                  }
                  {
                    name = "tmp";
                    emptyDir.sizeLimit = "500Mi";
                  }
                ];
              };
            };
          };
        };
      };

      services = {
        gotenberg = {
          metadata = {
            inherit namespace;
            name = "gotenberg";
          };
          spec = {
            selector = {
              app = "gotenberg";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 3000;
              }
            ];
          };
        };
      };
    };
  };
}
