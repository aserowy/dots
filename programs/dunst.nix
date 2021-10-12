{ config, pkgs, ... }:
{
  home.file.".config/dunst/dunstrc" = {
    source = ./dunst.config;
  };

  home.packages = with pkgs; [
    dunst
  ];
}

