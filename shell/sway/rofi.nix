{ config, pkgs, ... }:
{
  home.file.".config/rofi/" = {
    recursive = true;
    source = ./rofi;
  };

  home.packages = with pkgs; [
    rofi
  ];
}
