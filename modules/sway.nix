{ config, pkgs, ... }:
{
  imports = [
    ../programs/alacritty.nix
    ../programs/dunst.nix
    #../programs/eww.nix
    ../programs/gtk.nix
    ../programs/lf.nix
    ../programs/ncspot.nix
    ../programs/onedrive.nix
    ../programs/rofi.nix
    ../programs/sway.nix
    ../programs/waybar.nix
  ];
}
