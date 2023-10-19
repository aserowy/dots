{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.waybar;
in
{
  options.home.modules.waybar.enable = mkEnableOption "waybar";

  config = mkIf cnfg.enable {
    home = {
      # FIX: sleep 0.1 in config is a workaround for
      # https://github.com/Alexays/Waybar/issues/1850
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
