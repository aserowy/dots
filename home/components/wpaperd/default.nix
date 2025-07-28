{
  config,
  lib,
  ...
}:
with lib;

let
  cnfg = config.home.components.wpaperd;
in
{
  options.home.components.wpaperd = {
    enable = mkEnableOption "wpaperd";

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the wpaperd script gets added to niris config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    services.wpaperd = {
      enable = true;
      settings = {
        default = {
          duration = "30m";
          group = 1;
          mode = "center";
          path = "~/onedrive/Wallpapers/";
          sorting = "random";

          transition.linear-blur = {
            intensity = 0.05;
          };
        };
      };
    };

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "wpaperd"
    '';
  };
}
