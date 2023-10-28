{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.edge;
in
{
  options.home.components.edge = {
    enable = mkEnableOption "edge";

    enableDunstIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, edge gets set as default browser in dunst.
      '';
    };

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
      microsoft-edge-beta
    ];

    home.components.dunst.browserPath = mkIf cnfg.enableDunstIntegration
      "${pkgs.microsoft-edge-beta}/bin/microsoft-edge-beta";

    # INFO: set edge as default browser for electron apps
    home.sessionVariables.DEFAULT_BROWSER = mkIf cnfg.setDefaultBrowserSessionVariable
      "${pkgs.microsoft-edge-beta}/bin/microsoft-edge-beta";

    xdg.mimeApps.associations.added = mkIf cnfg.enableXdgAssociations {
      "text/html" = "microsoft-edge-beta.desktop";
      "x-scheme-handler/http" = "microsoft-edge-beta.desktop";
      "x-scheme-handler/https" = "microsoft-edge-beta.desktop";
      "x-scheme-handler/about" = "microsoft-edge-beta.desktop";
      "x-scheme-handler/unknown" = "microsoft-edge-beta.desktop";
    };
  };
}
