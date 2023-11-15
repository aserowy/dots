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
      default = true;
      description = ''
        If enabled, foot gets set as default terminal in Hyprland.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "yes";
          font = "UbuntuMonoNerdFont:size=10";
          line-height = 12;
          term = "xterm-256color";
        };
      };
    };

    home.modules.hyprland.defaultTerminal = mkIf cnfg.enableAsHyprlandDefaultTerminal "foot";
  };
}
