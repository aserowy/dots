{ config, pkgs, ... }:
{
  home.file.".config/kanata.kbd" = {
    source = ./kanata.kbd;
  };

  home.packages = with pkgs; [
    kanata
  ];
}
