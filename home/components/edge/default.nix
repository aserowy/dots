{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.edge;
in
{
  options.home.components.edge = {
    enable = mkEnableOption "edge";

    enableXdgAssociations = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, edge gets set as default browser in xdg.
      '';
    };

    setDefaultBrowserSessionVariable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, edge gets set as default browser with DEFAULT_BROWSER.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      (microsoft-edge.override {
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
          "--ozone-platform=wayland"
        ];
      })
    ];

    # INFO: set edge as default browser for electron apps
    home.sessionVariables.DEFAULT_BROWSER = mkIf cnfg.setDefaultBrowserSessionVariable "${pkgs.microsoft-edge}/bin/microsoft-edge";

    xdg.mimeApps.associations.added = mkIf cnfg.enableXdgAssociations {
      "text/html" = "microsoft-edge.desktop";
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
      "x-scheme-handler/about" = "microsoft-edge.desktop";
      "x-scheme-handler/unknown" = "microsoft-edge.desktop";
    };
  };
}
