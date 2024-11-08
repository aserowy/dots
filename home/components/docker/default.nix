{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

# TODO: meta package? Thus, module?
let
  cnfg = config.home.components.docker;
in
{
  options.home.components.docker.enable = mkEnableOption "docker";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}
