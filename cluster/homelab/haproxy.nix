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

        values = { };
      };

      # haproxy = {
      #   chart = charts.haproxytech.haproxy;
      #
      #   values = {
      #     config = "
      #     global
      #       log stdout format raw local0
      #       maxconn 1024
      #
      #     defaults
      #       log global
      #       timeout client 60s
      #       timeout connect 60s
      #       timeout server 60s";
      #   };
      # };
    };
  };
}
