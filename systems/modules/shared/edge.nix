{ pkgs, ... }:
{
  environment = {
    sessionVariables = {
      /* set edge as default browser for electron apps */
      DEFAULT_BROWSER = "${pkgs.microsoft-edge-beta}/microsoft-edge";
    };
    systemPackages = with pkgs; [
      microsoft-edge-beta
    ];
  };

  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "text/html" = "microsoft-edge-beta.desktop";
        "x-scheme-handler/http" = "microsoft-edge-beta.desktop";
        "x-scheme-handler/https" = "microsoft-edge-beta.desktop";
        "x-scheme-handler/about" = "microsoft-edge-beta.desktop";
        "x-scheme-handler/unknown" = "microsoft-edge-beta.desktop";
      };
    };
  };
}
