{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.onedrive;
in
{
  options.home.components.onedrive.enable = mkEnableOption "onedrive";

  config = mkIf cnfg.enable {
    home = {
      file.".config/onedrive/config" = {
        source = ./onedrive.config;
      };

      packages = [ pkgs.onedrivegui ];
    };
  };
}
