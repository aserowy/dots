{ config, lib, pkgs, ... }:

with lib;
let
  cnfg = config.home.modules.eww;
in
{
  options.home.modules.eww = {
    enable = mkEnableOption "eww";

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, eww gets started while running hyprland.
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

      # https://dharmx.is-a.dev/eww-powermenu/#tips
      # https://elkowar.github.io/eww/widgets.html
      file.".config/eww/eww.css".source = ./eww.css;
      file.".config/eww/eww.yuck".source = ./eww.yuck;
      file.".config/eww/widgets/".source = ./widgets;

      packages = with pkgs; [
        eww-wayland
      ];
    };

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Init eww
      exec-once = eww open sidebar
    '';
  };
}
