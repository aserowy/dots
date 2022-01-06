{ config, pkgs, ... }:
{
  home.file.".config/nvim/" = {
    recursive = true;
    source = pkgs.sources.neocode.src;
  };

  home.packages = with pkgs; [
    pkgs.fzf
    pkgs.gcc
    pkgs.gnumake
    pkgs.neovim
    pkgs.ripgrep
    pkgs.unzip
  ];
}
