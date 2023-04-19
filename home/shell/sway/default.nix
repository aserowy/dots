{ config, pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix

    ./grimshot.nix
    ./teams.nix
  ];
}
