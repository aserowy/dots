{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.neovim;
in
{
  # TODO: remove overlay and use options instead (flake nix)
  options.home.neovim.enable = mkEnableOption "neovim";

  config = mkIf cnfg.enable {
    home = {
      file.".config/nvim/" = {
        recursive = true;
        source = pkgs.neocode.override {
          theme = "onedark";
          style = "darker";
        };
      };

      packages = with pkgs; [
        gcc
        gnumake
        neovim
        ripgrep
        unzip
      ];
    };

    programs.fzf = {
      enable = true;
    };
  };
}
