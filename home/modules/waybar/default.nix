{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.waybar;
in
{
  options.home.modules.waybar = {
    enable = mkEnableOption "waybar";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, waybar gets initialized while starting sway.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, waybar gets initialized while starting hyprland.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      components.rofi.enable = true;

      # FIX: sleep 0.1 in config is a workaround for
      # https://github.com/Alexays/Waybar/issues/1850
      file.".config/waybar".source = ./src;

      modules = {
        clipboard.enable = true;
        screenshot.enable = true;
      };

      packages = with pkgs; [
        pavucontrol
        playerctl
        slurp
        waybar
        wf-recorder
      ];
    };

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Start waybar as status bar
      exec-once = waybar
    '';

    home.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      exec waybar
    '';
  };
}
