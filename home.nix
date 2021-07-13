{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  home.username = "serowy";
  home.homeDirectory = "/home/serowy";

  home.stateVersion = "21.05";

  imports = [
    ./environments/home.nix
    ./environments/wsl.nix
  ];
}
