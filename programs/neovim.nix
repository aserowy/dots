{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  home.file.".config/nvim/".source = ./neovim;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
  };
}
