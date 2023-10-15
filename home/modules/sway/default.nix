{ config, pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ../shared/gtk.nix
    ../shared/onedrive.nix

    ./grimshot.nix
    ./teams.nix
  ];
}
