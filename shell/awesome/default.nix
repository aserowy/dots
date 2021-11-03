{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
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
