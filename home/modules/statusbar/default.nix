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

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, statusbar gets started while running niri.
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

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "sh" "-c" "eww open --config ~/.config/eww/statusbar/ statusbar --arg stacking=foreground"
    '';
  };
}
