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
          controller.service = {
            annotations = {
              "lbipam.cilium.io/sharing-cross-namespace" = "*";
              "lbipam.cilium.io/sharing-key" = "default-ippool";
            };
            labels = {
              "app.kubernetes.io/role" = "entrypoint";
            };
            type = "LoadBalancer";
            ports = {
              http = 8080;
              https = 8443;
            };
          };
        };
      };
    };
  };
}
