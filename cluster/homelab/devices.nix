{ charts, lib, ... }:
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

        values.udev.discovery = {
          enabled = true;
          resources = {
            cpuRequest = "80m";
            memoryRequest = "24Mi";
          };
        };
      };
    };

    resources = {
      daemonSets.akri-udev-discovery-daemonset.spec.template = {
        spec.containers.akri-udev-discovery.resources.limits = lib.mkForce null;
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
