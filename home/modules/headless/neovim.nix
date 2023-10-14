{ pkgs, ... }:
{
  imports = [
    ./fzf.nix
  ];

  home.file.".config/nvim/" = {
    recursive = true;
    source = pkgs.neocode.override {
      theme = "onedark";
      style = "darker";
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
