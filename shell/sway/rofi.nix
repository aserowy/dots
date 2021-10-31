{ config, pkgs, ... }:
{
  home.file.".config/rofi/" = {
    recursive = true;
    source = ./rofi;
  };
}
