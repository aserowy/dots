{ config, pkgs, ... }:
{
  home.file.".config/rofi/config.rasi" = {
    source = ./rofi.rasi;
  };

  home.packages = with pkgs; [
    rofi
  ];
}
