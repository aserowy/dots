{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    playerctl
    spicetify-cli
    spotify
  ];
}
