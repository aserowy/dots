{ config, pkgs, ... }:
{
  imports = [
    ../programs/git.nix
    ../programs/neovim-server.nix
    ../programs/pandoc.nix
    ../programs/ssh.nix
    ../programs/vscode.nix
  ];
}
