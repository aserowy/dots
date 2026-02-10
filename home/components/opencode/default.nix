{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.opencode;
in
{
  options.home.components.opencode.enable = mkEnableOption "opencode";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        opencode
      ];

      file.".config/opencode/opencode.json".source = ./opencode.json;
    };
  };
}
