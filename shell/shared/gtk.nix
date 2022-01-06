{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
  ];

  xdg = {
    portal = {
      enable = true;
      gtkUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };
  };
}
