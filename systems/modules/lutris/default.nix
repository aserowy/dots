# TODO: try move this into home space
{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.lutris;
in
{
  options.system.modules.lutris.enable = mkEnableOption "lutris";

  config = mkIf cnfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
    ];

    systemd.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';

    systemd.user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
  };
}
