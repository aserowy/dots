{ charts, ... }:
let
  namespace = "devices";
in
{
  applications.devices = {
    inherit namespace;
    createNamespace = true;

    helm.releases = {
      akri = {
        chart = charts.project-akri.akri;
      };
    };

    resources = {
    };
  };
}
