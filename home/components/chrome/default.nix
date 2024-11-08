{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.chrome;
in
{
  options.home.components.chrome = {
    enable = mkEnableOption "chrome";

    enableXdgAssociations = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, chrome gets set as default browser in xdg.
      '';
    };

    setDefaultBrowserSessionVariable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, chrome gets set as default browser with DEFAULT_BROWSER.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
          "--ozone-platform=wayland"
        ];
      })
    ];

    # INFO: set chrome as default browser for electron apps
    home.sessionVariables.DEFAULT_BROWSER = mkIf cnfg.setDefaultBrowserSessionVariable "${pkgs.google-chrome}/bin/google-chrome-stable";

    xdg.mimeApps.associations.added = mkIf cnfg.enableXdgAssociations {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
    };
  };
}
