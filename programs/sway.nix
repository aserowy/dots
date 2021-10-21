{ config, pkgs, ... }:
{
  home.file.".config/sway/" = {
    recursive = true;
    source = ./sway;
  };

  home.packages = with pkgs; [
    # TODO: style onedark in own .nix
    alacritty
    jq
    sway-unwrapped
    swaybg
    swayidle

    xorg.xlsclients
    xwayland
  ];

  programs.zsh = {
    initExtra = ''
      # set sway mark
      function sm() {
        swaymsg mark $1
      }
    '';
    loginExtra = ''
      if [[ "$(tty)" == /dev/tty1 ]]; then
        exec sway
      fi
    '';
  };
}
