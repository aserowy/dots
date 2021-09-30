{ config, pkgs, ... }:
{
  imports = [
    ../modules/development.nix
    ../modules/monitoring.nix
    ../modules/shell.nix
  ];
}
