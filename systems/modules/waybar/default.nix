{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.waybar;
in
{
  options.system.modules.waybar.enable = mkEnableOption "waybar";

  config = mkIf cnfg.enable {
    environment.systemPackages = with pkgs; [
      jq
      pavucontrol
      playerctl
      sway-contrib.grimshot
      swappy
      waybar
      wf-recorder
    ];

    environment.etc."xdg/waybar".source = ./src;
  };
}
