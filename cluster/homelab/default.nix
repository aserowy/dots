{ ... }:
{
  imports = [
    ./argocd.nix
    ./cilium.nix
    ./devices.nix
    ./dns
    ./dms
    ./homeassistant
    ./loadbalancer.nix
    ./monitoring.nix
    ./policies.nix
    ./secrets.nix
    ./storage.nix
  ];

  nixidy = {
    resourceImports = [
      ../crd/akri.nix
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
