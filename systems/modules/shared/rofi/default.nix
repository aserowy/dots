{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rofi
  ];

  environment.etc.rofi.source = ./src;
}
