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
        Extra commands that are appended to sway config.
      '';
    };
  };

  config =
    let
      swayConfig = builtins.readFile ./config;
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
          sway-unwrapped
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
