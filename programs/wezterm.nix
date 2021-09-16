{ config, pkgs, ... }:
{
  home.file.".config/wezterm/" = {
    recursive = true;
    source = ./wezterm;
  };

  home.packages = with pkgs; [
    pkgs.wezterm
  ];
}
