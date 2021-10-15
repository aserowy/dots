{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    ncurses

    unixtools.watch
  ];

  imports = [
    ../programs/direnv.nix
    ../programs/lf.nix
    ../programs/starship.nix
    ../programs/tmux.nix
    ../programs/wezterm.nix
    ../programs/zsh.nix
  ];
}
