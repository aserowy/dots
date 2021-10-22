{ config, pkgs, ... }:
{
  home.file.".config/waybar/" = {
    recursive = true;
    source = ./waybar;
  };

  home.packages = with pkgs; [
    waybar
  ];
}
