{ config, pkgs, ... }:
{
  home.file.".config/waybar/config" = {
    source = ./waybar.config;
  };

  home.file.".config/waybar/style.css" = {
    source = ./waybar.css;
  };

  home.packages = with pkgs; [
    waybar
  ];
}
