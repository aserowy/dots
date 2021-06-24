{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../modules/shell.nix
  ];
}
