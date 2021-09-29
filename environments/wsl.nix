{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  imports = [
    ./headless.nix
  ];
}
