{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.services.modules.xdg;
in
{
  options.services.modules.xdg.enable = mkEnableOption "xdg";

  config = mkIf cnfg.enable {
    xdg = {
      portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
      };
    };
  };
}
