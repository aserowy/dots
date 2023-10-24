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
      # FIX: sleep 0.1 in config is a workaround for
      # https://github.com/Alexays/Waybar/issues/1850
      file.".config/waybar".source = ./src;

      modules = {
        clipman.enable = true;
        grim.enable = true;
        rofi.enable = true;
        swappy.enable = true;
      };

      packages = with pkgs; [
        jq
        pavucontrol
        playerctl
        slurp
        waybar
        wf-recorder
      ];
    };

    home.modules.sway.swaybarCommand = mkIf cnfg.enableSwayIntegration ''
      waybar
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Start waybar as status bar
      exec-once = waybar
    '';
  };
}
