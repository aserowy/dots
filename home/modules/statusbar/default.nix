{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cnfg = config.home.modules.statusbar;
in
{
  options.home.modules.statusbar = {
    enable = mkEnableOption "statusbar";

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, statusbar gets started while running hyprland.
      '';
    };

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, statusbar gets started while running niri.
      '';
    };

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, statusbar gets started while running sway.
      '';
    };
  };

  config = mkIf cnfg.enable {

    home = {
      file.".config/eww/statusbar/eww.css".source = ./eww.css;
      file.".config/eww/statusbar/eww.yuck".source = ./eww.yuck;
      file.".config/eww/statusbar/widgets/".source = ./widgets;

      components.swaync.enable = true;

      modules = {
        clipboard.enable = true;
      };

      packages = with pkgs; [
        eww
        jq
        pavucontrol
        socat
      ];
    };

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Init statusbar
      exec-once = eww open --config ~/.config/eww/statusbar/ statusbar --arg stacking=bottom
    '';

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "sh" "-c" "eww open --config ~/.config/eww/statusbar/ statusbar --arg stacking=bottom"
    '';

    home.modules.sway.appendedConfig = mkIf cnfg.enableSwayIntegration ''
      # Init statusbar
      exec eww open --config ~/.config/eww/statusbar/ statusbar --arg stacking=bottom
    '';
  };
}
