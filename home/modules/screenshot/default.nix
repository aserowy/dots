{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.screenshot;
in
{
  options.home.modules.screenshot.enable = mkEnableOption "screenshot";

  config = mkIf cnfg.enable {
    home = {
      file.".config/screenshot".source = ./src;

      components = {
        swappy.enable = true;
      };

      packages = with pkgs; [
        grim
        jq
        slurp
      ];
    };
  };
}
