{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.neovim;
in
{
  options.home.modules.neovim = {
    enable = mkEnableOption "neovim";

    parallelTsBuild = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If disabled, the build process for treesitter languages will work sequentially.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      modules.fzf.enable = true;

      file.".config/nvim/" = {
        recursive = true;
        source = pkgs.neocode.override {
          theme = "onedark";
          style = "darker";

          syncBuild = !cnfg.parallelTsBuild;
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
