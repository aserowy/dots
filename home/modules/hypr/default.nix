{ config, lib, pkgs, ... }:

with lib;
let
  cnfg = config.home.modules.hyprland;
in
{
  options.home.modules.hyprland = {
    enable = mkEnableOption "hyprland";

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

    additionalConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to hyprland config.
      '';
    };
  };

  config =
    let
      hyprlandConfig = builtins.readFile ./hyprland.conf;

      tuiLaunch = tui: builtins.replaceStrings [ "[PROG]" ] [ tui ] cnfg.tuiLaunchCommand;
    in
    mkIf cnfg.enable {
      home = {
        components = {
          # foot = {
          alacritty = {
            enable = true;
            enableAsHyprlandDefaultTerminal = true;
          };
        };

        # TODO: enable configuration for tui explorer
        file = {
          ".config/hypr/hyprland.conf".source = builtins.toFile "hyprland-config" ''
            # programs
            $explorer = ${tuiLaunch "yeet"}
            $terminal = ${cnfg.defaultTerminal}

            # additional config
            ${cnfg.additionalConfig}

            # hyprland config
            ${hyprlandConfig}
          '';

          ".config/hypr/scripts".source = ./scripts;
        };

        modules = {
          browser.enable = true;
          clipboard.enable = true;
          statusbar.enable = true;
        };

        packages = with pkgs; [
          hyprland

          xorg.xlsclients
          xwayland
        ];

        sessionVariables = {
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
