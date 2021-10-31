{ config, pkgs, ... }:
let
  theme = "Materia-dark";
  font = "FiraCode Nerd Font Mono 10";
  cursor = "Paper";
  icon = "Paper";
in
{
  home.packages = with pkgs; [
    libappindicator-gtk3
    materia-theme
    paper-icon-theme
    xdg_utils
  ];

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
  };

  xdg = {
    enable = true;

    configFile."gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-font-name=${font}
      gtk-icon-theme-name=${icon}
      gtk-theme-name=${theme}
      gtk-cursor-theme-name=${cursor}
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintfull
      gtk-xft-rgba=none
    '';

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
