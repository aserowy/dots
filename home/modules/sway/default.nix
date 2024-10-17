{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.sway;
in
{
  options.home.modules.sway = {
    enable = mkEnableOption "sway";

    prependedConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to sway config.
      '';
    };

    appendedConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are appended to sway config.
      '';
    };

    defaultTerminal = mkOption {
      type = types.str;
      description = ''
        Sets default terminal in sway.
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
        };

        file = {
          ".config/sway/config".source = builtins.toFile "sway-config" ''
            ${cnfg.prependedConfig}

            # programs
            set $terminal ${cnfg.defaultTerminal}
            set $explorer ${tuiLaunch "yeet"}

            # sway config

            ${swayConfig}

            ${cnfg.appendedConfig}

            include ~/.config/sway/config.d/*
          '';

          ".config/sway/config.d/99_systemd_target.conf".source = ./systemd_target.conf;
          ".config/sway/scripts".source = ./scripts;
        };

        modules = {
          browser.enable = true;
          clipboard.enable = true;
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
          XDG_CURRENT_DESKTOP = "sway";
          XDG_SESSION_DESKTOP = "sway";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
