{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.gaming;
in
{
  options.home.modules.gaming = {
    enable = mkEnableOption "gaming";
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      xwayland
      xwayland-satellite
    ];
  };
}
