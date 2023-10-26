{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.teams;
in
{
  options.home.modules.teams.enable = mkEnableOption "teams";

  config = mkIf cnfg.enable {
    home = {
      components.chrome.enable = true;

      packages = with pkgs; [
        (pkgs.writeShellScriptBin "teams" ''
          ${google-chrome}/bin/google-chrome-stable \
            --new-window \
            --app=https://teams.microsoft.com 
        '')
      ];
    };
  };
}
