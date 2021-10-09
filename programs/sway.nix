{ config, pkgs, ... }:
{
  home.file.".config/sway/config" = {
    source = ./sway/sway.config;
  };

  home.file.".config/rofi/config.rasi" = {
    source = ./sway/rofi.config;
  };

  home.file.".config/waybar/config" = {
    source = ./sway/waybar.config;
  };

  home.file.".config/waybar/style.css" = {
    source = ./sway/waybar.css;
  };

  home.packages = with pkgs; [
    mako
    sway-unwrapped
    rofi
    waybar
    wl-clipboard

    pavucontrol
    ranger
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
