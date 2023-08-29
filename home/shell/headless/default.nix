{ pkgs, ... }:
{
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    acpi
    bat
    bottom
    curl
    ncurses
    psmisc
    tokei
    tree

    unixtools.watch
  ];

  imports = [
    ./direnv.nix
    ./docker.nix
    ./git.nix
    ./gitui.nix
    ./lf.nix
    ./ncspot.nix
    ./neovim.nix
    ./nushell.nix
    # ./pandoc.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./vscode-server.nix
    ./wezterm.nix
    ./zoxide.nix
  ];
}
