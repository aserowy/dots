{ config, pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ../shared/gtk.nix
    ../shared/obsidian.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix

    ./grimshot.nix
    ./teams.nix
  ];
}
