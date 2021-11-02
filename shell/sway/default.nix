{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
    gparted
    pavucontrol
    remmina
  ];

  imports = [
    ./alacritty.nix
    ./edge.nix
    ./grimshot.nix
    ./gtk.nix
    ./lf.nix
    ./onedrive.nix
    ./rofi.nix
    ./spotify.nix
    ./sway.nix
    ./teams.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
  ];
}
