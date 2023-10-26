{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.chrome;
in
{
  options.home.components.chrome.enable = mkEnableOption "chrome";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
          "--ozone-platform-hint=auto"
        ];
      })
    ];
  };
}
