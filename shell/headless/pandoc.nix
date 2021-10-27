{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.pandoc
    pkgs.texlive.combined.scheme-small
  ];
}
