{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jq
    rofi-wayland
  ];

  environment.etc.rofi.source = ./src;
}
