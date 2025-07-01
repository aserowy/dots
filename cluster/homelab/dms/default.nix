{ charts, ... }:
let
  application = "dms";
  namespace = application;
in
{
  imports = [
    (import ./gotenberg.nix { inherit application namespace; })
    (import ./paperless.nix { inherit application namespace; })
    (import ./tika.nix { inherit application namespace; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    helm.releases = {
      postgresql = {
        chart = charts.bitnami.postgresql;

        values = {
          auth = {
            database = "paperless";
            username = "paperless";
            existingSecret = "postgresql";
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./dms-secrets.sops.yaml)
    ];
  };
}
