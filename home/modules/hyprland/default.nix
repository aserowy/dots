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
        packages = with pkgs; [
          hyprland
        ];

        file.".config/hypr/hyprland.config".source = builtins.toFile "hyprland-config" ''
          # additional config

          ${cnfg.additionalConfig}

          # hyprland config

          ${hyprlandConfig}
        '';
      };
    };
}
