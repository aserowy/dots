{ charts, ... }:
let
  namespace = "cnpg-system";
in
{
  applications.monitoring = {
    inherit namespace;

    createNamespace = true;

    helm.releases.cloudnativepg = {
      chart = charts.cloudnative-pg.cloudnative-pg;

      values = { };
    };
  };
}
