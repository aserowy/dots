{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.vscode-server;
in
{
  options.home.components.vscode-server.enable = mkEnableOption "vscode server";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      wget
    ];
  };
}
