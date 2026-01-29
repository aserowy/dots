{ charts, ... }:
let
  namespace = "cnpg-system";
in
{
  applications.cloudnativepg = {
    inherit namespace;

    createNamespace = true;

    helm.releases.cloudnativepg = {
      chart = charts.cloudnative-pg.cloudnative-pg;

      values = { };
    };
  };
}
