{ config, pkgs, ... }:
{
  imports = [
    ../programs/zsh.nix
    ../programs/starship.nix
    ../programs/tmux.nix
  ];
}
