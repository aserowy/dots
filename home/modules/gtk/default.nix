{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.gtk;
in
{
  options.home.modules.gtk.enable = mkEnableOption "gtk";

  config =
    let
      theme = "Qogir";
      font = "Inter";
      icon = "Qogir";
    in
    mkIf cnfg.enable {
      home.packages = with pkgs; [
        libappindicator-gtk3
      ];

      gtk = {
        enable = true;
        font = {
          name = font;
          size = 10;
        };
        iconTheme = {
          name = icon;
          package = pkgs.qogir-icon-theme;
        };
        theme = {
          name = theme;
          package = pkgs.qogir-theme;
        };
      };
    };
}
