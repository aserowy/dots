{ config, pkgs, ... }:
{
  home.file.".config/sway/" = {
    recursive = true;
    source = ./sway;
  };

  programs.zsh = {
    loginExtra = ''
      if [[ "$(tty)" == /dev/tty1 ]]; then
          # first import environment variables from the login manager
          systemctl --user import-environment

          # then start the service
          exec systemctl --user start sway.service
      fi
    '';
  };
}
