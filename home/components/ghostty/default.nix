{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.ghostty;
in
{
  options.home.components.ghostty = {
    enable = mkEnableOption "ghostty";

    enableAsHyprlandDefaultTerminal = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, ghostty gets set as default terminal in Hyprland.
      '';
    };

    enableAsSwayDefaultTerminal = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, ghostty gets set as default terminal in sway.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/ghostty/config".source = ./ghostty.config;
      };

      packages = with pkgs; [
        ghostty
      ];
    };

    home.modules.hyprland = mkIf cnfg.enableAsHyprlandDefaultTerminal {
      defaultTerminal = "ghostty";
      tuiLaunchCommand = "ghostty -e [PROG]";
    };

    home.modules.sway = mkIf cnfg.enableAsSwayDefaultTerminal {
      defaultTerminal = "ghostty";
      tuiLaunchCommand = "ghostty -e [PROG]";
    };
  };
}
