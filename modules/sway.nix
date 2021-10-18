{ config, pkgs, ... }:
{
  imports = [
    ../programs/dunst.nix
    ../programs/eww.nix
    ../programs/lf.nix
    ../programs/onedrive.nix
    ../programs/rofi.nix
    ../programs/sway.nix
    ../programs/waybar.nix
  ];
}
