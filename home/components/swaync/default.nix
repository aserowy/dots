{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.swaync;
in
{
  options.home.components.swaync = {
    enable = mkEnableOption "swaync";

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swaync daemon gets initialized on startup.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/swaync/config.json".source = ./config.json;
        ".config/swaync/style.css".source = ./style.css;
      };

      packages = with pkgs; [
        swaynotificationcenter
      ];
    };

    home.modules.sway.prependedConfig = mkIf cnfg.autostart ''
      # Start swaync daemon
      exec swaync
    '';

    home.modules.niri.prependedConfig = mkIf cnfg.autostart ''
      spawn-at-startup "swaync"
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.autostart ''
      # Start swaync daemon
      exec-once = swaync
    '';
  };
}
