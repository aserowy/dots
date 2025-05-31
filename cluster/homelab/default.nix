{ ... }:
{
  imports = [
    ./argocd.nix
    ./cilium.nix
    ./loadbalancer.nix
    ./secrets.nix
  ];

  nixidy = {
    resourceImports = [
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
