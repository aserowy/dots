{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    waybar
  ];

  environment.etc."xdg/waybar".source = ./src;
}
