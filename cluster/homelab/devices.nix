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
        values = {
          udev.discovery.enabled = true;
        };
      };
    };

    ignoreDifferences = {
      "instances.akri.sh" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/names/categories" ];
      };
    };
  };
}
