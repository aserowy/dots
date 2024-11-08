{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.xdg;
in
{
  options.home.modules.xdg.enable = mkEnableOption "xdg";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      xdg-utils
    ];

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        desktop = "$HOME/desktop";
        documents = "$HOME/documents";
        download = "$HOME/downloads";
        music = "$HOME/music";
        pictures = "$HOME/pictures";
        publicShare = "$HOME/public";
        templates = "$HOME/documents/templates";
        videos = "$HOME/videos";
      };
    };
  };
}
