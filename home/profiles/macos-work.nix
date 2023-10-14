{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ../modules/headless
    ../modules/macos
  ];

  programs = {
    ssh.matchBlocks = { };
  };
}
