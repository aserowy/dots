{ charts, ... }:
let
  application = "nextcloud";
  namespace = application;
in
{
  imports = [
    (import ./nextcloud.nix {
      inherit
        application
        namespace
        charts
        ;
    })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];
  };
}
