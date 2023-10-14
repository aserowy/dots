{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.lf;
in
{
  options.home.lf.enable = mkEnableOption "lf";

  config = mkIf cnfg.enable {
    home = {
      file.".config/lf/lfrc" = {
        source = ./lf.config;
      };

      packages = with pkgs; [
        lf
      ];
    };
  };
}
