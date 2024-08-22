{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.rofi;

    # FIX: till https://github.com/davatorium/rofi/discussions/2008 got released
  rofi = pkgs.rofi-wayland.overrideAttrs (old: {
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      rev = "d88b475bad26a6ba60c85cd7830e441da5774cdb";
      sha256 = "sha256-0ER7iiTrStuca2cOyddYzwBoVE02Cdnlt2/5gZszSNs=";
    };
  });
in
{
  options.home.components.rofi = {
    enable = mkEnableOption "rofi";

    theme = mkOption {
      type = types.str;
      default = "dashboard-list-two";
      description = ''
        The theme to use for rofi.
      '';
    };

    enableDunstIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, chrome gets set as default browser in dunst.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      packages =  [
        rofi
      ];

      file = {
        ".config/rofi/scripts".source = ./scripts;
        ".config/rofi/themes".source = ./themes;

        ".config/rofi/config.rasi".source = builtins.toFile "rofi-config" ''
          @theme "${cnfg.theme}"
        '';
      };
    };

    home.components.dunst.dmenuCommand = mkIf cnfg.enableDunstIntegration
      "${pkgs.rofi-wayland}/bin/rofi -dmenu";
  };
}
