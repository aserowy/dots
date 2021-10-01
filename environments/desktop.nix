{ config, pkgs, ... }:
{
  imports = [
    ./headless.nix

    ../modules/collaboration.nix
    ../modules/development-gui.nix
  ];
}
