{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.zellij;
in
{
  options.home.components.zellij.enable = mkEnableOption "zellij";

  config = mkIf cnfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        simplified_ui = true;
        pane_frames = false;
      };
    };
  };
}
