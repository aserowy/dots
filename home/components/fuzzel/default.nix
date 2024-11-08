{
  pkgs,
  config,
  lib,
  ...
}:
with lib;

let
  cnfg = config.home.components.fuzzel;
in
{
  options.home.components.fuzzel.enable = mkEnableOption "fuzzel";

  config = mkIf cnfg.enable {
    home = {
      file.".config/fuzzel/fuzzel.ini".source = ./fuzzel.ini;

      packages = with pkgs; [
        fuzzel
      ];
    };
  };
}
