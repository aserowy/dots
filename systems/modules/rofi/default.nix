{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.rofi;
in
{
  options.system.modules.rofi.enable = mkEnableOption "rofi";

  config = mkIf cnfg.enable {
    environment.systemPackages = with pkgs; [
      rofi-wayland
    ];

    environment.etc.rofi.source = ./src;
  };
}
