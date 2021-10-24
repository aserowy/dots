{ config, pkgs, ... }:
{
  imports = [
    ./headless.nix

    ../modules/administration-gui.nix
    ../modules/audio.nix
    ../modules/browsing.nix
    ../modules/collaboration.nix
    ../modules/daw.nix
    ../modules/development-gui.nix
    ../modules/gaming.nix
    ../modules/remote_access.nix
    ../modules/sway.nix
  ];
}
