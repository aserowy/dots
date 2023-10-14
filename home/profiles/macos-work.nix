{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ../modules
    ../modules/headless
    ../modules/macos
  ];

  config.home = {
    fzf.enable = true;
    neovim.enable = true;
  };

  programs = {
    ssh.matchBlocks = { };
  };
}
