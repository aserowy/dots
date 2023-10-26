{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.wezterm;
in
{
  options.home.components.wezterm.enable = mkEnableOption "wezterm";

  config = mkIf cnfg.enable {
    home = {
      file.".config/wezterm/wezterm.lua" = {
        source = ./wezterm.lua;
      };

      packages = with pkgs; [
        wezterm
      ];
    };
  };
}
