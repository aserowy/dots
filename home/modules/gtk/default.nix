{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.gtk;
in
{
  options.home.modules.gtk.enable = mkEnableOption "gtk";

  config =
    let
      theme = "Fluent-Dark-compact";
      font = "Inter";
      icon = "Fluent";
    in
    mkIf cnfg.enable {
      home.packages = with pkgs; [
        gnome.gnome-tweaks
      ];

      gtk = {
        enable = true;
        font = {
          name = font;
          size = 10;
        };
        iconTheme = {
          name = icon;
          package = pkgs.fluent-icon-theme;
        };
        theme = {
          name = theme;
          package = pkgs.fluent-gtk-theme;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
    };
}
