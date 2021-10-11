{ config, pkgs, ... }:
{
  imports = [
    ../programs/lf.nix
    ../programs/onedrive.nix
    ../programs/rofi.nix
    ../programs/sway.nix
    ../programs/waybar.nix
  ];
}
