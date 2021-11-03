{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
    gparted
    remmina
  ];

  imports = [
    ./grimshot.nix
    ./gtk.nix
    ./onedrive.nix
    ./teams.nix
    ./vscode.nix
  ];
}
