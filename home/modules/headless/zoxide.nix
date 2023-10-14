{ config, pkgs, lib, ... }:
{
  imports = [
    ./fzf.nix
  ];

  programs.zoxide = {
    enable = true;
  };
}
