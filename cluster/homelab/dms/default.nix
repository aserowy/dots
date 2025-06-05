{ lib, ... }:
let
  namespace = "dms";
in
{
  applications.dms = {
    inherit namespace;
    createNamespace = true;

    helm.releases.valkey = {
      # TODO: renovate update template for this and remove nix helm?
      chart = lib.helm.downloadHelmChart {
        repo = "https://charts.bitnami.com/bitnami/";
        chart = "valkey";
        version = "3.0.9";
        chartHash = "sha256-zSLEopYHW05p7OxZlcusR9SQcmtGnKji6CcQPl9s0xA=";
      };

      values = {
      };
    };

    yamls = [
      (builtins.readFile ./dms-secrets.sops.yaml)
    ];

    resources = {
    };
  };
}
