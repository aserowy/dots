{ config, pkgs, ... }:
{
  programs.ncspot = {
    enable = true;
    settings = {
      gapless = true;
    };
  };
}
