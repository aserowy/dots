{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.television;
in
{
  options.home.components.television.enable = mkEnableOption "television";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        television
      ];

      file = {
        ".config/television/config.toml".source = ./config.toml;
      };

      modules.nushell.appendedConfig = ''
        mkdir ($nu.data-dir | path join "vendor/autoload")
        tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")
      '';
    };
  };
}
