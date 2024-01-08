{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.rio;
in
{
  options.home.components.rio = {
    enable = mkEnableOption "rio";

    enableAsHyprlandDefaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, rio gets set as default terminal in Hyprland.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/rio/config.toml" = {
          source = ./config.toml;
        };

        ".config/rio/themes" = {
          source = ./themes;
        };
      };

      packages = with pkgs; [
        rio
      ];
    };

    home.modules.hyprland = mkIf cnfg.enableAsHyprlandDefaultTerminal {
      defaultTerminal = "rio";
      tuiLaunchCommand = "rio --command [PROG]";
    };
  };
}
