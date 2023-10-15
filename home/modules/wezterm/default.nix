{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.wezterm;
in
{
  options.home.modules.wezterm.enable = mkEnableOption "wezterm";

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
