{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.zellij;
in
{
  options.home.components.zellij.enable = mkEnableOption "zellij";

  config = mkIf cnfg.enable {
    home = {
      file.".config/zellij/config.kdl".source = ./config.kdl;
      file.".config/zellij/layouts/compact.kdl".source = ./compact.kdl;

      packages = with pkgs; [
        zellij
      ];
    };
  };
}
