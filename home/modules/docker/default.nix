{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.docker;
in
{
  options.home.modules.docker.enable = mkEnableOption "docker";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}
