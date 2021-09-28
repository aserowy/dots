{ config, pkgs, ... }:
{
  home.file.".config/nvim/" = {
    recursive = true;
    source = ./neovim;
  };

  home.packages = with pkgs; [
    pkgs.fzf
    pkgs.gcc
    pkgs.neovim
    pkgs.ripgrep
    pkgs.unzip
  ];
}
