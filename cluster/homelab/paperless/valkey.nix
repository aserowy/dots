{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    helm.releases.valkey = {
      chart = charts.valkey.valkey;

      values = {
        auth = {
          enabled = true;
          usersExistingSecret = "valkey-users";
          aclUsers = {
            default.permissions = "~* &* +@all";
            paperless.permissions = "~* &* +@all";
          };
        };

        dataStorage = {
          enabled = true;
          className = "longhorn-nobackup";
          requestedSize = "2Gi";
        };
      };
    };

    resources.ciliumNetworkPolicies.valkey = {
      apiVersion = "cilium.io/v2";
      kind = "CiliumNetworkPolicy";
      metadata = {
        inherit namespace;
      };
      spec = {
        endpointSelector.matchLabels = {
          "app.kubernetes.io/name" = "valkey";
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
                    port = "6379";
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
