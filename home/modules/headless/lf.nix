{ config, pkgs, ... }:
{
  home.file.".config/lf/lfrc" = {
    source = ./lf.config;
  };

  home.packages = with pkgs; [
    lf
  ];
}
