{ config, pkgs, ... }:
{
  home.file.".config/sway/config" = {
    source = ./sway.config;
  };

  home.file.".config/sway/gsettings.sh" = {
    source = ./sway-gsettings.sh;
  };

  home.file.".config/sway/wallpaper.sh" = {
    source = ./sway-wallpaper.sh;
  };

  home.packages = with pkgs; [
    alacritty
    sway-unwrapped
    swaybg
    swayidle

    xorg.xlsclients
    xwayland
  ];

  programs.zsh.loginExtra = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway
    fi
  '';
}
