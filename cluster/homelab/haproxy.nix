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
          labels = {
            "app.kubernetes.io/role" = "entrypoint";
          };
          service = {
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
