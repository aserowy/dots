{ config, pkgs, neocode, ... }:
{
  home.file.".config/nvim/" = {
    recursive = true;
    source = pkgs.neocode.override { theme = "test"; };
    /* source = pkgs.neocode; */
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
