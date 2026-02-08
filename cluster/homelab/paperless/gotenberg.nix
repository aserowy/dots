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
            replicas = 3;
            selector.matchLabels."app.kubernetes.io/name" = "gotenberg";
            strategy.type = "RollingUpdate";
            template = {
              metadata.labels."app.kubernetes.io/name" = "gotenberg";
              spec = {
                securityContext = {
                  seccompProfile = {
                    type = "RuntimeDefault";
                  };
                };
                containers = [
                  {
                    name = "gotenberg";
                    image = "docker.io/gotenberg/gotenberg:8.26.0"; # docker/gotenberg/gotenberg@semver-coerced
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
                    resources.requests = {
                      cpu = "100m";
                      memory = "600Mi";
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
            selector."app.kubernetes.io/name" = "gotenberg";
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

      ciliumNetworkPolicies = {
        gotenberg = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "gotenberg";
            };
            ingress = [
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "paperless";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "3000";
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
