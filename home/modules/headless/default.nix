{ pkgs, ... }:
{
  imports = [
    ./docker.nix
    ./git.nix
    ./gitui.nix
    ./ssh.nix
    ./tmux.nix
    ./vscode-server.nix
  ];

  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    bat
    bottom
    curl
    ncurses
    tree

    unixtools.watch
  ];
}
