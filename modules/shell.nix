{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.curl
    pkgs.ncurses
    pkgs.tree

    pkgs.unixtools.watch
  ];

  imports = [
    ../programs/direnv.nix
    ../programs/starship.nix
    ../programs/tmux.nix
    ../programs/wezterm.nix
    ../programs/zsh.nix
  ];
}
