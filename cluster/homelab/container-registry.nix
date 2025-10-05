{ lib, ... }:
let
  namespace = "registry";
in
{
  applications.registry = {
    inherit namespace;
    createNamespace = true;

    helm.releases = {
      zot = {
        chart = lib.helm.downloadHelmChart {
          repo = "http://zotregistry.dev/helm-charts";
          chart ="project-zot";
          version = "2.1.8";
          chartHash = "";
        };

        values = {
        };
      };
    };

    # yamls = [
    #   (builtins.readFile ./registry-secrets.sops.yaml)
    # ];
  };
}
