{ config, pkgs, ... }:
{
  programs.ncspot = {
    enable = true;
    settings = {
      gapless = true;
      notify = true;
      use_nerdfont = true;
    };
  };
}
