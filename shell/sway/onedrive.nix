{ config, pkgs, ... }:
{
  home.file.".config/onedrive/config" = {
    source = ./onedrive.config;
  };

  home.packages = with pkgs; [
    onedrive
  ];
}
