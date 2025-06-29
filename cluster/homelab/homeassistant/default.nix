{ ... }:
let
  namespace = "homeassistant";
in
{
  applications.homeassistant = {
    inherit namespace;
    createNamespace = true;

    helm.releases = {
    };

    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)
    ];

    resources = {
    };
  };
}
