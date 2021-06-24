{ config, pkgs, ... }:
{
  imports = [
    ../programs/starship.nix
    ../programs/zsh.nix
  ];
}
