{ config, pkgs, ... }:
{
  home.file.".config/nvim/" = {
    recursive = true;
    source = ./neovim;
  };

  home.packages = with pkgs; [
    pkgs.gcc
    pkgs.unstable.neovim
    pkgs.ripgrep
    pkgs.unzip
  ];
}
