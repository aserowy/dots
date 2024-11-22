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

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the wpaperd script gets added to sways config.
      '';
    };

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the wpaperd script gets added to niris config.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the wpaperd script gets added to hyprland config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs.wpaperd = {
      enable = true;
      settings = {
        default = {
          duration = "30m";
          mode = "center";
          path = "~/onedrive/Wallpapers/";

          transition.doom = {
            bars = 50;
          };
        };
      };
    };

    home.modules.sway.prependedConfig = mkIf cnfg.enableSwayIntegration ''
      # Start wpaperd daemon and cycle through random wallpaper
      exec wpaperd
    '';

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "wpaperd"
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Start wpaperd daemon and cycle through random wallpaper
      exec-once = wpaperd
    '';
  };
}
