{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.swww;
in
{
  options.system.modules.swww = {
    enable = mkEnableOption "swww";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the swww script gets added to sways config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    environment = {
      etc = {
        "swww/wallpaper.sh".source = ./swww-wallpaper.sh;
      };

      systemPackages = with pkgs; [
        swww
      ];
    };

    system.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      exec /etc/swww/wallpaper.sh ~/onedrive/Wallpapers/
    '';
  };
}
