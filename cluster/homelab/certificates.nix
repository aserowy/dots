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
    resources.ciliumNetworkPolicies = {
      cainjector = {
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

      cert-manager = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector.matchLabels = {
            "app.kubernetes.io/name" = "cert-manager";
          };
          ingress = [
            # NOTE: metrics collector must get unblocked here
            {
              fromEntities = [
                "host"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "9403";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
          egress = [
            {
              toEntities = [
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
              toEntities = [
                "world"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "443";
                      protocol = "TCP";
                    }
                    {
                      port = "53";
                      protocol = "UDP";
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

      webhook = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector.matchLabels = {
            "app.kubernetes.io/name" = "webhook";
          };
          ingress = [
            # NOTE: metrics collector must get unblocked here
            {
              fromEntities = [
                "host"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "6080";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              fromEntities = [
                "kube-apiserver"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "443";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              # NOTE: startupapicheck node
              fromEntities = [
                "remote-node"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "10250";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
          egress = [
            {
              toEntities = [
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
