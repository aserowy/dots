{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.swaybg;
in
{
  options.home.components.swaybg = {
    enable = mkEnableOption "swaybg";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swaybg script gets added to sways config.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swaybg script gets added to hyprland config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file.".config/swaybg/wallpaper.sh".source = ./swaybg-wallpaper.sh;

      packages = with pkgs; [
        swaybg
      ];
    };

    home.modules.sway.prependedConfig = mkIf cnfg.enableSwayIntegration ''
      exec ~/.config/swaybg/wallpaper.sh
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      exec-once = ~/.config/swaybg/wallpaper.sh
    '';
  };
}
