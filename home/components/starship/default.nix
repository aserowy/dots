{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.starship;
in
{
  options.home.components.starship.enable = mkEnableOption "starship";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        starship
      ];

      file.".config/starship.toml".source = ./starship.toml;
    };
  };
}
