{ config, pkgs, ... }:
{
  home.file.".config/sway/" = {
    recursive = true;
    source = ./sway;
  };

  programs.zsh = {
    loginExtra = ''
      if [[ "$(tty)" == /dev/tty1 ]]; then
        exec sway
      fi
    '';
  };
}
