{ pkgs, ... }:
{
  imports = [
    ./docker.nix
    ./ssh.nix
    ./vscode-server.nix
  ];
}
