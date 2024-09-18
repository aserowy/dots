{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.foot;
in
{
  options.home.components.foot = {
    enable = mkEnableOption "foot";

    enableAsHyprlandDefaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, foot gets set as default terminal in Hyprland.
      '';
    };

    setDpiAware = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, foot will be set to be DPI aware.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          dpi-aware = mkIf cnfg.setDpiAware "yes";
          font = "JetBrainsMonoNerdFont:size=12";
          term = "xterm-256color";
        };
      };
    };

    home.modules.hyprland = mkIf cnfg.enableAsHyprlandDefaultTerminal {
      defaultTerminal = "foot";
      tuiLaunchCommand = "foot [PROG]";
    };
  };
}
