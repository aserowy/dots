{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    swappy
    sway-contrib.grimshot
  ];
}
