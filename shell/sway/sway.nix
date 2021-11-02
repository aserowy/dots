{ config, pkgs, ... }:
{
#  programs.zsh = {
#    loginExtra = ''
#      if [[ "$(tty)" == /dev/tty1 ]]; then
#        export XDG_CURRENT_DESKTOP=sway
#        export XDG_SESSION_TYPE=wayland
#
#        exec sway
#      fi
#    '';
#  };
}
