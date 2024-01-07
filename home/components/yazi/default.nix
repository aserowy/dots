{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.yazi;
in
{
  options.home.components.yazi.enable = mkEnableOption "yazi";

  config = mkIf cnfg.enable {
    home = {
      # file.".config/yazi/yazi.lua" = {
      #   source = ./yazi.lua;
      # };

      packages = with pkgs; [
        yazi
      ];
    };
  };
}
