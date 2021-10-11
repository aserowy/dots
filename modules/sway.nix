{ config, pkgs, ... }:
{
  imports = [
    ../programs/lf.nix
    ../programs/rofi.nix
    ../programs/sway.nix
    ../programs/waybar.nix
  ];
}
