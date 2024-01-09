{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.yazi;
in
{
  options.home.components.yazi.enable = mkEnableOption "yazi";

  config = mkIf cnfg.enable {
    # TODO: add extract command
    home = {
      file = {
        ".config/yazi/yazi.toml" = {
          source = ./yazi.toml;
        };
        ".config/yazi/theme.toml" = {
          source = ./theme.toml;
        };
      };

      packages = with pkgs; [
        yazi

        # NOTE: optional dependencies
        ffmpegthumbnailer
        fd
        file
        fzf
        jq
        poppler
        ripgrep
        unar
        zoxide
      ];
    };
  };
}
