{ config, pkgs, ... }:
{
  imports = [
    ../programs/starship.nix
    ../programs/tmux.nix
    ../programs/zsh.nix
  ];
}
