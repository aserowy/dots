{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.swaybg;
in
{
  options.system.modules.swaybg = {
    enable = mkEnableOption "swaybg";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the swaybg script gets added to sways config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    environment = {
      etc = {
        "swaybg/wallpaper.sh".source = ./wallpaper.sh;
      };

      systemPackages = with pkgs; [
        swaybg
      ];
    };

    system.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      exec /etc/swaybg/wallpaper.sh
    '';
  };
}
