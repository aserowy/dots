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
            labels = {
              "app.kubernetes.io/role" = "entrypoint";
            };
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
