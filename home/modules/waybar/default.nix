{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.waybar;
in
{
  options.home.modules.waybar.enable = mkEnableOption "waybar";

  config = mkIf cnfg.enable {
    home = {
      file.".config/waybar".source = ./src;

      modules.swappy.enable = true;

      packages = with pkgs; [
        jq
        pavucontrol
        playerctl
        sway-contrib.grimshot
        waybar
        wf-recorder
      ];
    };
  };
}
