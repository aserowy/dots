{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.grim;
in
{
  options.home.modules.grim.enable = mkEnableOption "grim";

  config = mkIf cnfg.enable {
    home = {
      file.".config/grim".source = ./src;

      packages = with pkgs; [
        grim
        jq
        slurp
      ];
    };
  };
}
