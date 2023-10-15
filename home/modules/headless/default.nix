{ pkgs, ... }:
{
  imports = [
    ./docker.nix
    ./ssh.nix
    ./vscode-server.nix
  ];

  home.stateVersion = "22.05";

}
