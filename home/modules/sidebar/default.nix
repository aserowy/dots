{ config, lib, pkgs, ... }:

with lib;
let
  cnfg = config.home.modules.sidebar;
in
{
  options.home.modules.sidebar = {
    enable = mkEnableOption "sidebar";

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, sidebar gets started while running hyprland.
      '';
    };

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, sidebar gets started while running sway.
      '';
    };

    dashboardBackgroundOpacity = mkOption {
      type = types.str;
      default = "0.4";
      description = ''
        Sets the opacity of the dashboard background.
      '';
    };
  };

  config =
    let
      ewwCss = builtins.readFile ./eww.css;
    in
    mkIf cnfg.enable {
      home = {
        components = {
          # TODO: rework dunst to mako (more active maintainer)
          # https://github.com/emersion/mako/blob/master/makoctl.1.scd
          dunst = {
            enable = true;
            hideNotifications = true;
          };
        };

        file.".config/eww/sidebar/eww.css".source = builtins.toFile "eww-sidebar-css" ''
          ${ewwCss}

          .dashboard {
            background-color: rgba(0, 0, 0, ${cnfg.dashboardBackgroundOpacity});
          }
        '';
        file.".config/eww/sidebar/eww.yuck".source = ./eww.yuck;
        file.".config/eww/sidebar/widgets/".source = ./widgets;

        packages = with pkgs; [
          eww
          playerctl
        ];
      };

      home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
        # Init sidebar
        exec-once = eww open --config ~/.config/eww/sidebar/ sidebar
      '';

      home.modules.sway.appendedConfig = mkIf cnfg.enableSwayIntegration ''
        # Init sidebar
        exec eww open --config ~/.config/eww/sidebar/ sidebar
      '';
    };
}
