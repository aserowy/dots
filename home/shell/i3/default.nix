{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
    gnome.gnome-screenshot
    gparted
    remmina
    teams
  ];

  imports = [
    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix
  ];
}
