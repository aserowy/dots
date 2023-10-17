{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.swww;
in
{
  options.home.modules.swww = {
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
    home = {
      file.".config/swww/wallpaper.sh".source = ./swww-wallpaper.sh;

      packages = with pkgs; [
        swww
      ];
    };

    home.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      # Start swww daemon and cycle through random wallpaper
      exec swww init
      exec bash ~/.config/swww/wallpaper.sh ~/onedrive/Wallpapers/
    '';
  };
}
