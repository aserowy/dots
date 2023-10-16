{ config, lib, pkgs, ... }:

with lib;
let cfg = config.home.modules.hyprland;

in {
  options.home.modules.hyprland = { enable = mkEnableOption "hyprland"; };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;

    # home.packages = with pkgs; [
    #   hyprland
    # ];
    #
    # home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
  };
}
