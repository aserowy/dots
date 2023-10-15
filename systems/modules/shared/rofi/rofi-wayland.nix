{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rofi-wayland
  ];

  environment.etc.rofi.source = ./src;
}
