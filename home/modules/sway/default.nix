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

    defaultTerminal = mkOption {
      type = types.str;
      description = ''
        Sets default terminal in hyprland.
      '';
    };

    tuiLaunchCommand = mkOption {
      type = types.str;
      description = ''
        Sets the command to launch tui. It is important to specify the
        placeholder [PROG] for the command which should get run.
      '';
    };
  };

  config =
    let
      swayConfig = builtins.readFile ./config;

      tuiLaunch = tui: builtins.replaceStrings [ "[PROG]" ] [ tui ] cnfg.tuiLaunchCommand;
    in
    mkIf cnfg.enable {
      home = {
        components = {
          alacritty = {
            enable = true;
            enableAsSwayDefaultTerminal = true;
          };

          rofi.enable = true;
          lf.enable = true;
        };

        file = {
          ".config/sway/config".source = builtins.toFile "sway-config" ''
            # programs
            set $terminal = ${cnfg.defaultTerminal}
            set $explorer = ${tuiLaunch "yeet"}

            # additional config

            ${cnfg.additionalConfig}

            # sway config

            ${swayConfig}

            include ~/.config/sway/config.d/*
          '';

          ".config/sway/config.d/99_systemd_target.conf".source = ./systemd_target.conf;
          ".config/sway/scripts".source = ./scripts;
        };

        modules = {
          browser.enable = true;
          clipboard.enable = true;
          notification.enable = true;
          sidebar.enable = true;
          statusbar.enable = true;
        };

        packages = with pkgs; [
          (sway.override {
            withGtkWrapper = true;
          })

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
