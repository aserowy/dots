{ config, pkgs, ... }:
let
  theme = "Materia-dark";
  font = "FiraCode Nerd Font Mono";
  icon = "Paper";
in
{
  home.packages = with pkgs; [
    libappindicator-gtk3
    xdg-utils
  ];

  gtk = {
    enable = true;
    font = {
      name = font;
      size = 10;
    };
    iconTheme = {
      name = icon;
      package = pkgs.paper-icon-theme;
    };
    theme = {
      name = theme;
      package = pkgs.materia-theme;
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "$HOME/desktop";
      documents = "$HOME/documents";
      download = "$HOME/downloads";
      music = "$HOME/music";
      pictures = "$HOME/pictures";
      publicShare = "$HOME/public";
      templates = "$HOME/documents/templates";
      videos = "$HOME/videos";
    };
  };
}
