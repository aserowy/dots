{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
  ];
}
