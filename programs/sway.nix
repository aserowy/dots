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
    wl-clipboard

    pavucontrol
    xdg-desktop-portal-wlr
  ];

  programs.zsh.loginExtra = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway
    fi
  '';
}
