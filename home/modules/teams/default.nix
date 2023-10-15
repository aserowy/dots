{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.teams;
in
{
  options.home.modules.teams.enable = mkEnableOption "teams";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      google-chrome

      (pkgs.writeShellScriptBin "teams" ''
        ${google-chrome}/bin/google-chrome-stable \
          --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
          --ozone-platform=wayland \
          --new-window \
          --app=https://teams.microsoft.com 
      '')
    ];
  };
}
