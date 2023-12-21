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
  };

  config = mkIf cnfg.enable {

    home = {
      components = {
        # TODO: rework dunst to mako (more active maintainer)
        # https://github.com/emersion/mako/blob/master/makoctl.1.scd
        dunst = {
          enable = true;
          hideNotifications = true;
        };
      };

      file.".config/eww/sidebar/eww.css".source = ./eww.css;
      file.".config/eww/sidebar/eww.yuck".source = ./eww.yuck;
      file.".config/eww/sidebar/widgets/".source = ./widgets;

      packages = with pkgs; [
        eww-wayland
      ];
    };

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Init sidebar
      exec-once = eww open --config ~/.config/eww/sidebar/ sidebar
    '';
  };
}
