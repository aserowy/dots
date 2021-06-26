{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../modules/development.nix
    ../modules/monitoring.nix
    ../modules/shell.nix
  ];
}
