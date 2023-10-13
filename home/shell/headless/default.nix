{ pkgs, ... }:
{
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    bat
    bottom
    curl
    ncurses
    tree

    unixtools.watch
  ];

  imports = [
    ./direnv.nix
    ./docker.nix
    ./git.nix
    ./gitui.nix
    ./lf.nix
    ./neovim.nix
    ./nushell.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./vscode-server.nix
    ./wezterm.nix
    ./zoxide.nix
  ];
}
