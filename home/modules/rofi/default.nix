{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.rofi;
in
{
  options.home.modules.rofi.enable = mkEnableOption "rofi";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        rofi-wayland
      ];

      file.".config/rofi/".source = ./src;
    };
  };
}
