{ charts, ... }:
let
  namespace = "haproxy";
in
{
  applications.haproxy = {
    inherit namespace;

    createNamespace = true;

    helm.releases.kubernetes-ingress = {
      chart = charts.haproxytech.kubernetes-ingress;

      values = {
        controller = {
          # NOTE: important to comply with cilium requirements
          service = {
            annotations = {
              "lbipam.cilium.io/sharing-cross-namespace" = "*";
              "lbipam.cilium.io/sharing-key" = "default-ippool";
            };
            labels = {
              "cilium/ippool" = "default-ippool";
            };
            type = "LoadBalancer";
          };
        };
      };
    };

    resources.ciliumClusterwideNetworkPolicies.haproxy = {
      apiVersion = "cilium.io/v2";
      kind = "CiliumClusterwideNetworkPolicy";
      metadata = {
        inherit namespace;
      };
      spec = {
        endpointSelector = {
          matchLabels = {
            "io.kubernetes.pod.namespace" = "haproxy";
            "app.kubernetes.io/name" = "kubernetes-ingress";
          };
        };
        ingress = [
          {
            fromEntities = [ "host" ];
            toPorts = [
              {
                ports = [
                  {
                    port = "1042";
                    protocol = "TCP";
                  }
                ];
              }
            ];
          }
          # NOTE: combining fromEndpoints and fromEntities is not supported
          {
            fromEntities = [ "world" ];
            toPorts = [
              {
                ports = [
                  {
                    port = "8443";
                    protocol = "TCP";
                  }
                ];
              }
            ];
          }
          {
            fromEndpoints = [
              { matchLabels."haproxy/ingress" = "allow"; }
            ];
            toPorts = [
              {
                ports = [
                  {
                    port = "8443";
                    protocol = "TCP";
                  }
                ];
              }
            ];
          }
        ];
        egress = [
          {
            toEntities = [ "kube-apiserver" ];
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
              { matchLabels."app.kubernetes.io/component" = "app"; }
              { matchLabels."haproxy/egress" = "allow"; }
            ];
          }
        ];
      };
    };
  };
}
