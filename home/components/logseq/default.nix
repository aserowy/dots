{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.logseq;
in
{
  options.home.components.logseq = {
    enable = mkEnableOption "logseq";

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled the logseq package will be installed.
      '';
    };

  };

  config = mkIf cnfg.enable {
    home = {
      # file.".logseq" = {
      #   source = ./config;
      # };

      packages = mkIf cnfg.installPackage [
        pkgs.logseq
      ];
    };
  };
}
