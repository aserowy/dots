{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.lf;
in
{
  options.home.components.lf.enable = mkEnableOption "lf";

  config = mkIf cnfg.enable {
    home = {
      file.".config/lf/icons".source = ./icons;
      file.".config/lf/lfrc".source = ./lf.config;

      packages = with pkgs; [
        lf
      ];
    };
  };
}
