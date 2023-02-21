{ config, pkgs, ... }:
{
  /* nixpkgs.config.allowUnfree = true; */

  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    conmon
    podman
  ];

  imports = [
    ../shell/headless
  ];

  programs.ssh.matchBlocks = { };
}
