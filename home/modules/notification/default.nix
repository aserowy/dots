{ config, lib, ... }:

with lib;
let
  cnfg = config.home.modules.notification;
in
{
  options.home.modules.notification.enable = mkEnableOption "notification";

  config = mkIf cnfg.enable {
    home = {
      components = {
        dunst.enable = true;

        edge = {
          enable = true;
          enableDunstIntegration = true;
        };

        rofi.enable = true;
      };
    };
  };
}
