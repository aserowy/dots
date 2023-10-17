{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.alacritty;
in
{
  options.home.modules.alacritty.enable = mkEnableOption "alacritty";

  config = mkIf cnfg.enable {
    home = {
      file.".config/alacritty/alacritty.yaml".source = ./alacritty.yaml;

      packages = with pkgs; [
        alacritty
      ];
    };
  };
}
