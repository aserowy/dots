{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
  ];

  imports = [
    ../programs/git.nix
    ../programs/neovim.nix
    ../programs/pandoc.nix
    ../programs/ssh.nix
    ../programs/vscode.nix
  ];
}
