{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
  ];

  imports = [
    ../programs/git.nix
    ../programs/neovim.nix
    ../programs/ssh.nix
  ];
}
