{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.rofi;
in
{
  options.home.components.rofi = {
    enable = mkEnableOption "rofi";

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

      file.".config/rofi/".source = ./src;
    };

    home.components.dunst.dmenuCommand = mkIf cnfg.enableDunstIntegration
      "${pkgs.rofi-wayland}/bin/rofi -dmenu";
  };
}
