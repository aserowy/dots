{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.clipman;
in
{
  options.home.modules.clipman = {
    enable = mkEnableOption "clipman";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, init clipman with wl-clipboard tools in sway.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, init clipman with wl-clipboard tools in hyprland.
      '';
    };
  };

  config = {
    home = {
      packages = with pkgs; [
        clipman
        wl-clipboard
      ];
    };

    home.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      # Init clipman with wl-clipboard tools
      exec wl-paste -t text --watch clipman store --no-persist
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Init clipman with wl-clipboard tools
      exec-once = wl-paste -t text --watch clipman store --no-persist
    '';
  };
}
