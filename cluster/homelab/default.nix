{ ... }:
{
  imports = [
    ./argocd.nix

    ./caching.nix
    ./certificates.nix
    ./cilium.nix
    ./devices.nix
    ./loadbalancer.nix
    ./monitoring.nix
    ./policies.nix
    ./secrets.nix
    ./storage.nix

    ./adguard
    ./homeassistant
    ./paperless
  ];

  nixidy = {
    resourceImports = [
      # ../crd/akri.nix
      ../crd/cert-manager.nix
      ../crd/cilium.nix
      ../crd/sops.nix
      ../crd/traefik.nix
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
