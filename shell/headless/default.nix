{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    acpi
    bottom
    curl
    ncurses

    unixtools.watch
  ];

  imports = [
    ./direnv.nix
    ./git.nix
    ./lf.nix
    ./ncspot.nix
    ./neovim.nix
    ./pandoc.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./vscode-server.nix
    ./wezterm.nix
    ./zsh.nix
  ];
}
