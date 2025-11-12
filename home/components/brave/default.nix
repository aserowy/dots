{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.brave;
in
{
  options.home.components.brave = {
    enable = mkEnableOption "brave";

    enableXdgAssociations = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, brave gets set as default browser in xdg.
      '';
    };

    setDefaultBrowserSessionVariable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, brave gets set as default browser with DEFAULT_BROWSER.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };

    # INFO: set brave as default browser for electron apps
    home.sessionVariables.DEFAULT_BROWSER = mkIf cnfg.setDefaultBrowserSessionVariable "${pkgs.brave}/bin/brave";

    xdg.mimeApps.associations.added = mkIf cnfg.enableXdgAssociations {
      "text/html" = "brave.desktop";
      "x-scheme-handler/http" = "brave.desktop";
      "x-scheme-handler/https" = "brave.desktop";
      "x-scheme-handler/about" = "brave.desktop";
      "x-scheme-handler/unknown" = "brave.desktop";
    };
  };
}
