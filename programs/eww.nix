{ config, pkgs, ... }:
{
  home.file.".config/eww/" = {
    recursive = true;
    source = ./eww;
  };

  home.packages = with pkgs; [
    eww
  ];
}
