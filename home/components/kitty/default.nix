{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.kitty;
in
{
  options.home.components.kitty.enable = mkEnableOption "kitty";

  config = mkIf cnfg.enable {
    programs = {
      kitty = {
        enable = true;
        font = {
          name = "JetBrainsMonoNerdFont";
          size = 12;
        };
        themeFile = "BlulocoDark";
      };
    };
  };
}
