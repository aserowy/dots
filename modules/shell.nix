{ config, pkgs, ... }:
{
  imports = [
    ../programs/zsh.nix
    ../programs/starship.nix
  ];
}
