{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.ghostty;
in
{
  options.home.components.ghostty = {
    enable = mkEnableOption "ghostty";
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/ghostty/config".source = ./ghostty.config;
      };

      packages = with pkgs; [
        ghostty
      ];
    };
  };
}
