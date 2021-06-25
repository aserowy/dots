{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../modules/development.nix
    ../modules/shell.nix
  ];
}
