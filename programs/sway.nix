{ config, pkgs, ... }:
{
  home.file.".config/sway/config" = {
    source = ./sway.config;
  };

  home.packages = with pkgs; [
    mako
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
  programs.fish.loginShellInit = ''
    if test (tty) = /dev/tty1
      exec sway
    end
  '';
  programs.bash.profileExtra = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway
    fi
  '';
}
