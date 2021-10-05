{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
    /* edge */
  ];
}
