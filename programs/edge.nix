{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    /* edge */
    firefox
  ];
}
