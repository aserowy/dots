{ charts, ... }:
let
  namespace = "haproxy";
in
{
  applications.haproxy = {
    inherit namespace;

    createNamespace = true;

    helm.releases.haproxy = {
      chart = charts.haproxytech.haproxy;

      values = {
      };
    };
  };
}
