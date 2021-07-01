{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  home.file.".config/nvim/" = {
    recursive = true;
    source = ./neovim;
  };

  home.packages = with pkgs; [
    pkgs.gcc
    pkgs.neovim-nightly
    pkgs.ripgrep
    pkgs.unzip
  ];
}
