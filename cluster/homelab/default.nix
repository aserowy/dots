{ ... }:
{
  imports = [
    ./argocd.nix

    ./certificates.nix
    ./cilium.nix
    ./devices.nix
    ./haproxy.nix
    ./monitoring.nix
    ./policies.nix
    ./secrets.nix
    ./storage.nix

    ./adguard
    ./cloudnativepg.nix
    ./homeassistant
    ./nextcloud
    ./paperless
    ./rustdesk.nix
  ];

  nixidy = {
    resourceImports = [
      # ../crd/akri.nix
      ../crd/cert-manager.nix
      ../crd/cilium.nix
      ../crd/sops.nix
    ];

    target = {
      repository = "https://github.com/aserowy/dots.git";
      branch = "homelab";
      rootPath = "./";
    };

    defaults = {
      syncPolicy = {
        autoSync = {
          enabled = true;
          prune = true;
          selfHeal = true;
        };
      };
    };
  };
}
