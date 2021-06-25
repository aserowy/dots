{ config, pkgs, ... }:
{
  imports = [
    ../programs/direnv.nix
    ../programs/starship.nix
    ../programs/tmux.nix
    ../programs/zsh.nix
  ];
}
