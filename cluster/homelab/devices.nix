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
      daemonSets.akri-agent-daemonset.spec.template = {
        spec.containers.akri-agent.resources.limits = lib.mkForce null;
      };
      daemonSets.akri-udev-discovery-daemonset.spec.template = {
        spec.containers.akri-udev-discovery.resources.limits = lib.mkForce null;
      };
      deployments.akri-controller-deployment.spec.template = {
        spec.containers.akri-controller.resources.limits = lib.mkForce null;
      };
      deployments.akri-webhook-configuration.spec.template = {
        spec.containers.webhook.resources.limits = lib.mkForce null;
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
