{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.swww;
in
{
  options.home.components.swww = {
    enable = mkEnableOption "swww";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swww script gets added to sways config.
      '';
    };

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swww script gets added to niris config.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swww script gets added to hyprland config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file.".config/swww/wallpaper.sh".source = ./swww-wallpaper.sh;

      packages = with pkgs; [
        swww
      ];
    };

    home.modules.sway.prependedConfig = mkIf cnfg.enableSwayIntegration ''
      # Start swww daemon and cycle through random wallpaper
      exec swww-daemon
      exec bash ~/.config/swww/wallpaper.sh ~/onedrive/Wallpapers/
    '';

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "swww-daemon"
      spawn-at-startup "bash" "~/.config/swww/wallpaper.sh" "~/onedrive/Wallpapers/"
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Start swww daemon and cycle through random wallpaper
      exec-once = swww-daemon
      exec-once = bash ~/.config/swww/wallpaper.sh ~/onedrive/Wallpapers/
    '';
  };
}
