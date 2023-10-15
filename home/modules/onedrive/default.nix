{ config, lib, ... }:
with lib;

let
  cnfg = config.home.modules.onedrive;
in
{
  options.home.modules.onedrive.enable = mkEnableOption "onedrive";

  config = mkIf cnfg.enable {
    home.file.".config/onedrive/config" = {
      source = ./onedrive.config;
    };
  };
}
