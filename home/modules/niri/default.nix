{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.niri;
in
{
  options.home.modules.niri = {
    enable = mkEnableOption "niri";

    prependedConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to niri config.
      '';
    };
  };

  config =
    let
      niriConfig = builtins.readFile ./config.kdl;
    in
    mkIf cnfg.enable {
      home = {
        components = {
          alacritty = {
            enable = true;
          };

          rofi.enable = true;
        };

        file = {
          ".config/niri/config.kdl".source = builtins.toFile "niri-config" ''
            ${cnfg.prependedConfig}

            ${niriConfig}
          '';
        };

        modules = {
          browser.enable = true;
          clipboard.enable = true;
          notification.enable = true;

          sidebar = {
            enable = true;
            dashboardBackgroundOpacity = "0.75";
          };

          statusbar.enable = true;
        };

        packages = with pkgs; [
          gamescope
          niri
        ];

        sessionVariables = {
          SDL_VIDEODRIVER = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
