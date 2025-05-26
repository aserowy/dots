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
  options.home.components.onedrive = {
    enable = mkEnableOption "onedrive";

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, init onedrivegui on startup
      '';
    };
  };

  config = mkIf cnfg.enable {
    home.packages = [
      pkgs.onedrive
      pkgs.onedrivegui
    ];

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "onedrivegui"
    '';
  };
}
