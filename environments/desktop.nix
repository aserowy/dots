{ config, pkgs, ... }:
{
  imports = [
    ./headless.nix

    ../modules/development-gui.nix
  ];
}
