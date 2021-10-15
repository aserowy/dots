{ config, pkgs, ... }:
{
  imports = [
    ./headless.nix

    ../modules/administration-gui.nix
    ../modules/audio.nix
    ../modules/browsing.nix
    ../modules/collaboration.nix
    ../modules/development-gui.nix
    ../modules/remote_access.nix
    ../modules/sway.nix
  ];
}
