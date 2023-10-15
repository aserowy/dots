{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.sway;
in
{
  options.system.modules.sway.enable = mkEnableOption "sway";

  imports = [
    ../alacritty
  ];

  config = mkIf cnfg.enable {
    system.modules = {
      alacritty.enable = true;
    };
  };
}
