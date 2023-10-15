{ config, pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ../shared/gtk.nix

    ./grimshot.nix
    ./teams.nix
  ];
}
