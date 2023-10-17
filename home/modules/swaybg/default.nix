{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.swaybg;
in
{
  options.home.modules.swaybg = {
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
    home = {
      file.".config/swaybg/wallpaper.sh".source = ./swaybg-wallpaper.sh;

      packages = with pkgs; [
        swaybg
      ];
    };

    home.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      exec ~/.config/swaybg/wallpaper.sh
    '';
  };
}
