{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.gaming;
in
{
  options.home.modules.gaming = {
    enable = mkEnableOption "gaming";

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, xwayland-satellite gets started while running niri.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      gamescope
      xwayland
      xwayland-satellite

      # NOTE: xbox controller support
      xboxdrv
    ];

    xdg.desktopEntries = {
      "gamescoped.steam" = {
        name = "GameScoped Steam";
        genericName = "Steam";
        exec = "${pkgs.gamescope}/bin/gamescope -w 3440 -h 1440 --steam -- steam -pipewire-dmabuf";
        icon = "steam";
        categories = [ "Game" ];
      };
    };

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "xwayland-satellite"
    '';

    home.sessionVariables = mkIf cnfg.enableNiriIntegration {
      DISPLAY = ":0";
    };
  };
}
