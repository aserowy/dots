{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.gaming;

  mkUnless = condition: onTrue: onFalse: mkMerge [
    (mkIf condition onTrue)
    (mkIf (!condition) onFalse)
  ];
in
{
  options.home.modules.gaming = {
    enable = mkEnableOption "gaming";

    enableXwaylandSatellite = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, xwayland-satellite gets started while running niri.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      xwayland
      xwayland-satellite

      # NOTE: xbox controller support
      xboxdrv
    ];

    home.modules.niri.prependedConfig = mkIf cnfg.enableXwaylandSatellite ''
      spawn-at-startup "xwayland-satellite"
    '';

    # NOTE: sdl with wayland, x11 and windows is for easy anti cheat support on wine
    home.sessionVariables = mkUnless cnfg.enableXwaylandSatellite
      {
        # FIX: envs are not present when using rofi to launch eg steam
        DISPLAY = ":0";
        SDL_VIDEODRIVER = "wayland,x11,windows";
      }
      {
        SDL_VIDEODRIVER = "wayland";
      };
  };
}
