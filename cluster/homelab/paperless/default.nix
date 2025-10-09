{ charts, ... }:
let
  application = "paperless";
  namespace = application;
in
{
  imports = [
    (import ./gotenberg.nix { inherit application namespace; })
    (import ./paperless.nix { inherit application namespace charts; })
    (import ./tika.nix { inherit application namespace; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./paperless-secrets.sops.yaml)
    ];
  };
}
