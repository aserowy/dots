{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.chrome;
in
{
  options.home.components.chrome = {
    enable = mkEnableOption "chrome";

    enableDunstIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, chrome gets set as default browser in dunst.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
          "--ozone-platform-hint=auto"
        ];
      })
    ];

    home.components.dunst.browserPath = mkIf cnfg.enableDunstIntegration
      "${pkgs.google-chrome}/bin/google-chrome-stable";
  };
}
