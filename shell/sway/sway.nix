{ config, pkgs, ... }:
{
  home.file.".config/sway/" = {
    recursive = true;
    source = ./sway;
  };

  programs.zsh = {
    loginExtra = ''
      if [[ "$(tty)" == /dev/tty1 ]]; then
        dbus-update-activation-environment --systemd --all
        dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP=sway

        exec systemctl --user start sway.service
      fi
    '';
  };
}
