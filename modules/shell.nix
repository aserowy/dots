{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.ncurses
  ];

  imports = [
    ../programs/direnv.nix
    ../programs/starship.nix
    ../programs/tmux.nix
    ../programs/zsh.nix
  ];
}
