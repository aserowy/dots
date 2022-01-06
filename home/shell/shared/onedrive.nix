{ config, pkgs, ... }:
{
  home.file.".config/onedrive/config" = {
    source = ./onedrive.config;
  };
}
