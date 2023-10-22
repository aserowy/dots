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

      # TODO: modulize wl-clipboard and clipman
      # TODO: add clipman rofi as icon to waybar
      # TODO: refactor grimshot into nu script with slurp
      # "on-click-middle": "sleep 0.1 && grimshot --notify save window - | swappy -f -",
      # swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -g - screenshot.png
      # hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - screenshot.png

      modules = {
        rofi.enable = true;
        swappy.enable = true;
      };

      packages = with pkgs; [
        jq
        pavucontrol
        playerctl
        slurp
        sway-contrib.grimshot
        waybar
        wf-recorder
      ];
    };
  };
}
