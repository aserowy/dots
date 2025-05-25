{
  config,
  lib,
  # pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.edge;

  system = "x86_64-linux";

  # FIX: remove after edge maintainer found
  pkgs =
    import
      (builtins.fetchGit {
        name = "microsoft-edge-revision";
        url = "https://github.com/NixOS/nixpkgs/";
        ref = "refs/heads/nixos-unstable";
        rev = "75500d4f1a1e62df4939f1702aea338109711377";
      })
      {
        inherit system;
        config.allowUnfree = true;
      };

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
