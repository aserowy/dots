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
          edge.enable = true;
          launcher.enable = true;
          lf.enable = true;
          waybar.enable = true;
          wezterm.enable = true;
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
