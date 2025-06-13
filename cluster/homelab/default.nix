{ ... }:
{
  imports = [
    ./argocd.nix
    ./cilium.nix
    ./dns
    ./dms
    ./loadbalancer.nix
    # ./monitoring.nix
    ./policies.nix
    ./secrets.nix
    ./storage.nix
  ];

  nixidy = {
    resourceImports = [
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
