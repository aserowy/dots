{ config, pkgs, ... }:
{
  home.file.".config/sway/config" = {
    source = ./sway.config;
  };

  home.file.".config/sway/wallpaper.sh" = {
    source = ./sway-wallpaper.sh;
  };

  home.packages = with pkgs; [
    sway-unwrapped
    swaybg
    swayidle

    xorg.xlsclients

    glfw-wayland
    libsForQt5.qt5.qtwayland
    xdg-desktop-portal-wlr
    xwayland
  ];

  programs.zsh.loginExtra = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway
    fi
  '';
}
