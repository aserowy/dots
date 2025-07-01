{ charts, ... }:
let
  application = "homeassistant";
  namespace = application;
in
{
  imports = [
    (import ./emqx.nix { inherit application charts; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)
    ];
  };
}
