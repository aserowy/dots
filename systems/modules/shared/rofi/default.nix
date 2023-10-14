{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jq
    rofi
  ];

  environment.etc.rofi.source = ./src;
}
