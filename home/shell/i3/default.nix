{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnome.gnome-screenshot
    teams
  ];

  imports = [
    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix
  ];
}
