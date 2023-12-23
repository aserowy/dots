{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.direnv;
in
{
  options.home.components.direnv.enable = mkEnableOption "direnv";

  config = mkIf cnfg.enable {
    programs = {
      direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
      };
    };
  };
}
