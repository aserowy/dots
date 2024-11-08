{ charts, ... }:
{
  imports = [
    (import ./argocd.nix { inherit charts; })
  ];

  nixidy = {
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
