{ application, namespace, ... }:
{
  applications."${application}".resources = {
    deployments.tika = {
      apiVersion = "apps/v1";
      metadata = {
        inherit namespace;
        name = "tika";
      };
      spec = {
        replicas = 1;
        selector.matchLabels."app.kubernetes.io/name" = "tika";
        strategy.type = "RollingUpdate";
        template = {
          metadata.labels."app.kubernetes.io/name" = "tika";
          spec = {
            securityContext.seccompProfile = {
              type = "RuntimeDefault";
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
                resources.requests = {
                  cpu = "400m";
                  memory = "320Mi";
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

    services.tika = {
      metadata = {
        inherit namespace;
        name = "tika";
      };
      spec = {
        selector."app.kubernetes.io/name" = "tika";
        ports = [
          {
            name = "http";
            protocol = "TCP";
            port = 9998;
          }
        ];
      };
    };

    ciliumNetworkPolicies.tika = {
      apiVersion = "cilium.io/v2";
      kind = "CiliumNetworkPolicy";
      metadata = {
        inherit namespace;
      };
      spec = {
        endpointSelector.matchLabels."app.kubernetes.io/name" = "tika";
        ingress = [
          {
            fromEndpoints = [
              {
                matchLabels."app.kubernetes.io/name" = "paperless";
              }
            ];
            toPorts = [
              {
                ports = [
                  {
                    port = "9998";
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
}
