{ config, lib, pkgs, ... }:

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
  };

  config = mkIf cnfg.enable {

    home = {
      file.".config/eww/statusbar/eww.css".source = ./eww.css;
      file.".config/eww/statusbar/eww.yuck".source = ./eww.yuck;
      file.".config/eww/statusbar/widgets/".source = ./widgets;

      modules = {
        clipboard.enable = true;
        screenshot.enable = true;
      };

      packages = with pkgs; [
        eww-wayland
        jq
        pavucontrol
        slurp
        socat
        wf-recorder
      ];
    };

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Init statusbar
      exec-once = eww open --config ~/.config/eww/statusbar/ statusbar
    '';
  };
}
