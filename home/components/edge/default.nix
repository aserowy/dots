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
      default = true;
      description = ''
        If enabled, edge gets set as default browser in dunst.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      sessionVariables = {
        /* set edge as default browser for electron apps */
        DEFAULT_BROWSER = "${pkgs.microsoft-edge-beta}/microsoft-edge";
      };

      packages = with pkgs; [
        microsoft-edge-beta
      ];
    };

    xdg = {
      mimeApps = {
        enable = true;
        associations.added = {
          "text/html" = "microsoft-edge-beta.desktop";
          "x-scheme-handler/http" = "microsoft-edge-beta.desktop";
          "x-scheme-handler/https" = "microsoft-edge-beta.desktop";
          "x-scheme-handler/about" = "microsoft-edge-beta.desktop";
          "x-scheme-handler/unknown" = "microsoft-edge-beta.desktop";
        };
      };
    };

    home.components.dunst.browserPath = mkIf cnfg.enableDunstIntegration
      "${pkgs.microsoft-edge-beta}/microsoft-edge-beta";
  };
}
