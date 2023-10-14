{ config, pkgs, ... }:
{
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    ardour
    discord
    gparted
    remmina
  ];
}
