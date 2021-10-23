{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pavucontrol
  ];

  imports = [
    ../programs/spotify.nix
  ];
}
