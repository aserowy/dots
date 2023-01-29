{ config, pkgs, neocode, ... }:
{
  imports = [
    ./fzf.nix
  ];

  home.file.".config/nvim/" = {
    recursive = true;
    source = pkgs.neocode.override {
      theme = "onedark";
      style = "dark";
    };
  };

  home.packages = with pkgs; [
    pkgs.gcc
    pkgs.gnumake
    pkgs.neovim
    pkgs.ripgrep
    pkgs.unzip
  ];
}
