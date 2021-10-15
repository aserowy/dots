{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pavucontrol
  ];

  imports = [
    ../programs/ncspot.nix
  ];
}
