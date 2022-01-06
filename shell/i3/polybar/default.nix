{ config, pkgs, ... }:
let
  polybarOverride = pkgs.polybar.override {
    alsaSupport = true;
    i3GapsSupport = true;
    iwSupport = true;
    pulseSupport = true;
  };
in
{
  environment = {
    etc = {
      "polybar".source = ./src;
    };

    systemPackages = with pkgs; [
      killall
      polybarOverride

      (pkgs.writeShellScriptBin "polybar-launch" ''
        #!/bin/sh

        killall -q .polybar-wrapper
        while pgrep -u $UID -x .polybar-wrapper >/dev/null; do sleep 1; done

        polybar -q main -c /etc/polybar/config.ini &
      '')
    ];
  };
}
