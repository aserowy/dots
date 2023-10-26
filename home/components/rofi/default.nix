{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.rofi;
in
{
  options.home.components.rofi.enable = mkEnableOption "rofi";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        rofi-wayland
      ];

      file.".config/rofi/".source = ./src;
    };
  };
}
