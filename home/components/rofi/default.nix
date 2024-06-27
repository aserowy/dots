{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.rofi;
in
{
  options.home.components.rofi = {
    enable = mkEnableOption "rofi";

    theme = mkOption {
      type = types.str;
      default = "clear-list-two";
      description = ''
        The theme to use for rofi.
      '';
    };

    enableDunstIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, chrome gets set as default browser in dunst.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        rofi-wayland
      ];

      file = {
        ".config/rofi/scripts".source = ./scripts;
        ".config/rofi/themes".source = ./themes;

        ".config/rofi/config.rasi".source = builtins.toFile "rofi-config" ''
          @import "themes/${cnfg.theme}.rasi"
        '';
      };

    };

    home.components.dunst.dmenuCommand = mkIf cnfg.enableDunstIntegration
      "${pkgs.rofi-wayland}/bin/rofi -dmenu";
  };
}
