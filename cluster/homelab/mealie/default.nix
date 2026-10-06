{ ... }:
let
  application = "mealie";
  namespace = application;
in
{
  imports = [
    (import ./mealie.nix { inherit application namespace; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./mealie-secrets.sops.yaml)
    ];
  };
}
