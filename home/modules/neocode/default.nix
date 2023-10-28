{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.neocode;
in
{
  options.home.modules.neocode = {
    enable = mkEnableOption "neocode";

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
      components.fzf.enable = true;

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