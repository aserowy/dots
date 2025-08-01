{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.alacritty;
in
{
  options.home.components.alacritty = {
    enable = mkEnableOption "alacritty";
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/alacritty/alacritty.toml".source = ./alacritty.toml;
        ".config/alacritty/themes".source = ./themes;
      };

      packages = with pkgs; [
        alacritty
      ];
    };
  };
}
