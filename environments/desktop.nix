{ config, pkgs, ... }:
{
  imports = [
    ./headless.nix

    ../modules/browsing.nix
    ../modules/collaboration.nix
    ../modules/development-gui.nix
    ../modules/remote_access.nix
  ];
}
