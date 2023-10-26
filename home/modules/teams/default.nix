{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.teams;
in
{
  options.home.modules.teams.enable = mkEnableOption "teams";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
          "--ozone-platform-hint=auto"
        ];
      })

      (pkgs.writeShellScriptBin "teams" ''
        ${google-chrome}/bin/google-chrome-stable \
          --new-window \
          --app=https://teams.microsoft.com 
      '')
    ];
  };
}
