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

    swaybarCommand = mkOption {
      type = types.str;
      default = "";
      description = ''
        Command that is used to start status bar with swaybar_command.
      '';
    };
  };

  config =
    let
      swayConfig = builtins.readFile ./config;

      swayPackage = pkgs.sway.override {
        withGtkWrapper = true;
      };

      swaybarCommand = mkIf cnfg.swaybarCommand != ""
        "swaybar_command ${cnfg.swaybarCommand}";
    in
    mkIf cnfg.enable {
      home = {
        components = {
          edge.enable = true;
          rofi.enable = true;
          lf.enable = true;
          wezterm.enable = true;
        };

        file = {
          ".config/sway/config".source = builtins.toFile "sway-config" ''
            # additional config

            ${cnfg.additionalConfig}

            # sway config

            ${swayConfig}

            # bar and systemd_target

            bar {
                ${swaybarCommand}
            }

            include ~/.config/sway/config.d/*
          '';

          ".config/sway/config.d/99_systemd_target.conf".source = ./systemd_target.conf;
          ".config/sway/scripts".source = ./scripts;
        };

        modules = {
          clipboard.enable = true;
          notification.enable = true;
          waybar.enable = true;
        };

        packages = with pkgs; [
          swayPackage

          xorg.xlsclients
          xwayland
        ];

        sessionVariables = {
          SDL_VIDEODRIVER = "wayland";
          XDG_CURRENT_DESKTOP = "sway";
          XDG_SESSION_DESKTOP = "sway";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
