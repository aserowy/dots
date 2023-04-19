{ config, pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ../shared/edge.nix
    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix

    ./grimshot.nix
  ];
}
