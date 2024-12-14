{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.anyrun;
in
{
  options.home.components.anyrun = {
    enable = mkEnableOption "anyrun";
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/anyrun/config.ron".source = ./config.ron;
        ".config/anyrun/style.css".source = ./style.css;
      };

      packages = with pkgs; [
        anyrun
      ];
    };
  };
}
