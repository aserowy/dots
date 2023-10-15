{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.neovim;
in
{
  # TODO: remove overlay and use options instead (flake nix)
  options.home.modules.neovim.enable = mkEnableOption "neovim";

  config = mkIf cnfg.enable {
    home = {
      modules.fzf.enable = true;

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
  };
}
