{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.wezterm;
in
{
  options.home.components.wezterm = {
    enable = mkEnableOption "wezterm";

    enableAsHyprlandDefaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, wezterm gets set as default terminal in Hyprland.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file.".config/wezterm/wezterm.lua" = {
        source = ./wezterm.lua;
      };

      packages = with pkgs; [
        wezterm
      ];
    };

    home.modules.hyprland = mkIf cnfg.enableAsHyprlandDefaultTerminal {
      defaultTerminal = "wezterm";
      tuiLaunchCommand = "wezterm start --class [PROG] -- [PROG]";
    };
  };
}
