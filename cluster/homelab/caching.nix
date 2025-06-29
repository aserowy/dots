{ charts, ... }:
let
  namespace = "caching";
in
{
  applications.caching = {
    inherit namespace;
    createNamespace = true;

    helm.releases = {
      valkey = {
        chart = charts.bitnami.valkey;

        values = {
          auth = {
            existingSecret = "valkey";
            existingSecretPasswordKey = "password";
          };
          primary = {
            persistence = {
              size = "4Gi";
            };
          };
          replica = {
            persistence = {
              size = "4Gi";
            };
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./caching-secrets.sops.yaml)
    ];
  };
}
