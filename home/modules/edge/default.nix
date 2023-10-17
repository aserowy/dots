{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.edge;
in
{
  options.home.modules.edge.enable = mkEnableOption "edge";

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
  };
}
