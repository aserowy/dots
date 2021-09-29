{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./headless.nix

    ../modules/development-gui.nix
  ];
}
