{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.vscode-server;
in
{
  options.home.modules.vscode-server.enable = mkEnableOption "vscode server";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      wget
    ];
  };
}
