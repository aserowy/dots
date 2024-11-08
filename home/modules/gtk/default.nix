{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.gtk;
in
{
  options.home.modules.gtk.enable = mkEnableOption "gtk";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      gnome-tweaks
    ];

    gtk = {
      enable = true;

      cursorTheme = {
        name = "Vanilla-DMZ";
        package = pkgs.vanilla-dmz;
      };

      font = {
        name = "Inter";
        size = 10;
      };

      iconTheme = {
        name = "Fluent";
        package = pkgs.fluent-icon-theme;
      };

      theme = {
        name = "Fluent-Dark-compact";
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
