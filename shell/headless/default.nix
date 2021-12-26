{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    acpi
    bat
    bottom
    curl
    ncurses
    psmisc
    tokei

    unixtools.watch
  ];

  imports = [
    ./direnv.nix
    ./docker.nix
    ./git.nix
    ./lf.nix
    ./mcfly.nix
    ./ncspot.nix
    ./neovim.nix
    ./pandoc.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./vscode-server.nix
    ./wezterm.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
