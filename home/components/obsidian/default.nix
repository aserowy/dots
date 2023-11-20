{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.obsidian;
in
{
  options.home.components.obsidian.enable = mkEnableOption "obsidian";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      (obsidian.override {
        electron = electron_24;
      })
    ];
  };
}
