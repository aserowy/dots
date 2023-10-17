{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.services.modules.gtk;
in
{
  options.services.modules.gtk.enable = mkEnableOption "gtk";

  config = mkIf cnfg.enable {
    environment.systemPackages = with pkgs; [
      gtk-engine-murrine
      gtk_engines
      gsettings-desktop-schemas
      lxappearance
    ];

    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        wlr.enable = true;
      };
    };
  };
}
