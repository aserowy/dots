# {[345320:345320:1017/140335.250983:ERROR:screen_capture_portal_interface.cc(78)] Failed to request the session subscription.
# [345320:345320:1017/140335.251000:ERROR:base_capturer_pipewire.cc(81)] ScreenCastPortal failed: 3

{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.sway;
in
{
  options.home.modules.sway = {
    enable = mkEnableOption "sway";

    additionalConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to sway config.
      '';
    };
  };

  config =
    let
      swayConfig = builtins.readFile ./config;

      swayPackage = pkgs.sway.override {
        withGtkWrapper = true;
      };

    in
    mkIf cnfg.enable {
      home = {
        file = {
          ".config/sway/config".source = builtins.toFile "sway-config" ''
            # additional config

            ${cnfg.additionalConfig}

            # sway config

            ${swayConfig}
          '';

          ".config/sway/config.d/99_systemd_target.conf".source = ./systemd_target.conf;
          ".config/sway/scripts".source = ./scripts;
        };

        modules = {
          alacritty.enable = true;
          edge.enable = true;
          rofi.enable = true;
          waybar.enable = true;
        };

        packages = with pkgs; [
          clipman
          lf
          pv
          swayPackage
          wezterm
          wf-recorder
          wl-clipboard

          xorg.xlsclients
          xwayland
        ];

        sessionVariables = {
          # INFO: sets ozone wayland support for all chromium based applications
          NIXOS_OZONE_WL = "1";
          SDL_VIDEODRIVER = "wayland";
          XDG_CURRENT_DESKTOP = "sway";
          XDG_SESSION_DESKTOP = "sway";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
