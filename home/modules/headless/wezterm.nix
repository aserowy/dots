{ config, pkgs, ... }:
{
  home.file.".config/wezterm/wezterm.lua" = {
    source = ./wezterm.lua;
  };

  home.packages = with pkgs; [
    wezterm
  ];
}
