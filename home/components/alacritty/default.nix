{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.alacritty;
in
{
  options.home.components.alacritty = {
    enable = mkEnableOption "alacritty";

    enableAsHyprlandDefaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, alacritty gets set as default terminal in Hyprland.
      '';
    };

    enableAsSwayDefaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, alacritty gets set as default terminal in sway.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/alacritty/alacritty.toml".source = ./alacritty.toml;
        ".config/alacritty/themes".source = ./themes;
      };

      packages = with pkgs; [
        alacritty
      ];
    };

    home.modules.hyprland = mkIf cnfg.enableAsHyprlandDefaultTerminal {
      defaultTerminal = "alacritty";
      tuiLaunchCommand = "alacritty --command [PROG]";
    };

    home.modules.sway = mkIf cnfg.enableAsSwayDefaultTerminal {
      defaultTerminal = "alacritty";
      tuiLaunchCommand = "alacritty --command [PROG]";
    };
  };
}
