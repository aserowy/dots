{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.sway;
in
{
  options.system.modules.sway.enable = mkEnableOption "sway";

  imports = [
    ../alacritty
    ../waybar
  ];

  config = mkIf cnfg.enable {
    environment = {
      etc = {
        "sway/config".source = ./config;
        "sway/config.d/99_systemd_target.conf".source = ./systemd_target.conf;

        "sway/scripts".source = ./scripts;
      };

      sessionVariables = {
        # INFO: sets ozone wayland support for all chromium based applications
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
        XDG_SESSION_DESKTOP = "sway";
        XDG_SESSION_TYPE = "wayland";
      };
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        clipman
        lf
        pv
        sway-unwrapped
        swaybg
        wezterm
        wf-recorder
        wl-clipboard

        xorg.xlsclients
        xwayland
      ];
    };

    system.modules = {
      alacritty.enable = true;
      waybar.enable = true;
    };

    systemd.user = {
      targets.sway-session = {
        description = "Sway compositor session";
        documentation = [ "man:systemd.special(7)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
    };
  };
}
