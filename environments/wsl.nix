{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  imports = [
    ../modules/development.nix
    ../modules/monitoring.nix
    ../modules/shell.nix
  ];
}
