{ pkgs, ... }:
{
  imports = [
    ./docker.nix
    ./vscode-server.nix
  ];
}
