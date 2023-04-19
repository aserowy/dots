{ config, pkgs, ... }:
{
  services.chrome-pwa.enable = true;

  environment = {
    sessionVariables = {
      /* set edge as default browser for electron apps */
      DEFAULT_BROWSER = "${pkgs.microsoft-edge}/microsoft-edge";
    };
    systemPackages = with pkgs; [
      microsoft-edge
    ];
  };

  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "text/html" = "microsoft-edge.desktop";
        "x-scheme-handler/http" = "microsoft-edge.desktop";
        "x-scheme-handler/https" = "microsoft-edge.desktop";
        "x-scheme-handler/about" = "microsoft-edge.desktop";
        "x-scheme-handler/unknown" = "microsoft-edge.desktop";
      };
    };
  };
}
