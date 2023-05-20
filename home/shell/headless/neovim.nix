{ pkgs, ... }:
{
  imports = [
    ./fzf.nix
  ];

  home.file.".config/nvim/" = {
    recursive = true;
    source = pkgs.neocode.override {
      theme = "github";
      style = "dark_dimmed";
    };
  };

  home.packages = with pkgs; [
    gcc
    gnumake
    neovim
    ripgrep
    unzip
  ];
}
