{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.waybar;
in
{
  options.home.modules.waybar.enable = mkEnableOption "waybar";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        jq
        pavucontrol
        playerctl
        sway-contrib.grimshot
        swappy
        waybar
        wf-recorder
      ];

      file.".config/waybar".source = ./src;
    };
  };
}
