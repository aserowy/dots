{ pkgs, ... }:
{
  imports = [
    ./docker.nix
    ./ssh.nix
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
