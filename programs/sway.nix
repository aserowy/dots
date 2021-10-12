{ config, pkgs, ... }:
{
  home.file.".config/sway/config" = {
    source = ./sway.config;
  };

  home.packages = with pkgs; [
    sway-unwrapped
    swaybg
    swayidle
    wallutils
    wl-clipboard

    pavucontrol
    xdg-desktop-portal-wlr
  ];

  programs.zsh.loginExtra = ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec sway
    fi
  '';

  systemd.user = {
    startServices = "sd-switch";

    services.wallpaper-refresh = {
      Unit = {
        Description = "Wallpaper refresh every hour";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "setrandom ~/onedrive/Wallpapers/";
      };
    };

    timers.wallpaper-refresh = {
      Install = {
        WantedBy = [ "timers.target" ];
      };
      Timer = {
        OnUnitActiveSec = "1h";
      };
    };
  };
}
