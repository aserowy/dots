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
    in
    mkIf cnfg.enable {
      home = {
        components = {
          lf.enable = true;
          rofi.enable = true;

          foot = {
            enable = true;
            enableAsHyprlandDefaultTerminal = true;
          };
        };

        file = {
          ".config/hypr/hyprland.conf".source = builtins.toFile "hyprland-config" ''
            # programs
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
          eww.enable = true;
          clipboard.enable = true;
          notification.enable = true;
          waybar.enable = true;
        };

        packages = with pkgs; [
          hyprland

          xorg.xlsclients
          xwayland
        ];

        sessionVariables = {
          SDL_VIDEODRIVER = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
