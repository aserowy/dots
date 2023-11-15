{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.foot;
in
{
  options.home.components.foot.enable = mkEnableOption "foot";

  config = mkIf cnfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "yes";
          font = "UbuntuMonoNerdFont:size=11";
          term = "xterm-256color";
        };
      };
    };
  };
}
