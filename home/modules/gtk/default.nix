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
      adw-gtk3
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

      theme.name = "adw-gtk3";

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        color-scheme = "prefer-dark";
      };
    };
  };
}
