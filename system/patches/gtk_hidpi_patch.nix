{ config, pkgs, ... }:
{
  services.xserver.dpi = 192;

  environment.variables = {
    GDK_SCALE = "0.5";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=0.5";
    XCURSOR_SIZE = "32";
  };
}
