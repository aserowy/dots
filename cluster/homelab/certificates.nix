{ charts, ... }:
let
  namespace = "certificates";
in
{
  applications.certificates = {
    inherit namespace;

    createNamespace = true;

    helm.releases = {
      cert-manager = {
        chart = charts.jetstack.cert-manager;

        values = {
          crds.enabled = true;
        };
      };
    };

    # NOTE: https://cert-manager.io/docs/installation/best-practice/#network-requirements
    ciliumNetworkPolicies = {
      rustdesk = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector.matchLabels = {
            "app.kubernetes.io/name" = "cainjector";
          };
          ingress = [
            # NOTE: metrics collector must get unblocked here
            { }
          ];
          egress = [
            {
              toEntities = [
                "host"
                "kube-apiserver"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "6443";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "kube-system";
                    "k8s-app" = "kube-dns";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "53";
                      protocol = "UDP";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
