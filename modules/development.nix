{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.nixpkgs-fmt
  ];

  imports = [
    ../programs/git.nix
    ../programs/neovim.nix
    ../programs/ssh.nix
  ];
}
