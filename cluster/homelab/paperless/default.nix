{ charts, lib, ... }:
let
  application = "paperless";
  namespace = application;
in
{
  imports = [
    (import ./gotenberg.nix { inherit application namespace; })
    (import ./paperless.nix {
      inherit
        application
        namespace
        charts
        lib
        ;
    })
    (import ./tika.nix { inherit application namespace; })
    (import ./valkey.nix {
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
      (builtins.readFile ./paperless-secrets.sops.yaml)
    ];
  };
}
