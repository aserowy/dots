{ charts, ... }:
let
  namespace = "haproxy";
in
{
  applications.haproxy = {
    inherit namespace;

    createNamespace = true;

    helm.releases = {
      kubernetes-ingress = {
        chart = charts.haproxytech.kubernetes-ingress;

        values = {
          controller = {
            service = {
              annotations = {
                "lbipam.cilium.io/sharing-cross-namespace" = "*";
                "lbipam.cilium.io/sharing-key" = "default-ippool";
              };
              # NOTE: important to comply with cilium requirements
              type = "LoadBalancer";
            };
          };
        };
      };
    };
  };
}
