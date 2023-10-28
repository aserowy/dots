{ config, lib, pkgs, ... }:

with lib;
let cnfg = config.home.modules.hyprland;

in {
  options.home.modules.hyprland = {
    enable = mkEnableOption "hyprland";

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
          edge.enable = true;
          lf.enable = true;
          rofi.enable = true;
          wezterm.enable = true;
        };

        file = {
          ".config/hypr/hyprland.conf".source = builtins.toFile "hyprland-config" ''
            # additional config

            ${cnfg.additionalConfig}

            # hyprland config

            ${hyprlandConfig}
          '';

          ".config/hypr/scripts".source = ./scripts;
        };

        modules = {
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
