{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.lf;
in
{
  options.home.modules.lf.enable = mkEnableOption "lf";

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
