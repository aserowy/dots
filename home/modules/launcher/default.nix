{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.launcher;
in
{
  options.home.modules.launcher.enable = mkEnableOption "launcher";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        rofi-wayland
      ];

      file.".config/rofi/".source = ./src;
    };
  };
}
