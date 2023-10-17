{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.lutris;
in
{
  options.home.modules.lutris.enable = mkEnableOption "lutris";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      lutris
    ];
  };
}
