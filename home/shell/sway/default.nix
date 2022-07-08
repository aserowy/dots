{ config, pkgs, ... }:
{
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    ardour
    gparted
    remmina
  ];

  imports = [
    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix

    ./grimshot.nix
    ./teams.nix
    ./discord.nix
  ];
}
