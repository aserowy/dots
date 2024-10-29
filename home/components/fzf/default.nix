{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.fzf;
in
{
  options.home.components.fzf.enable = mkEnableOption "fzf";

  config = mkIf cnfg.enable {
    programs.fzf = {
      enable = true;
      colors = {
        "fg" = "#b9c0cb";
        "fg+" = "#ffffff";
        "bg" = "#282c34";
        "bg+" = "#282c34";
        "hl" = "#10b1fe";
        "hl+" = "#10b1fe";
        "info" = "#25a45c";
        "prompt" = "#ff936a";
        "pointer" = "#3476ff";
        "marker" = "#ff6480";
        "spinner" = "#3476ff";
        "header" = "#7a82da";
      };
      fileWidgetOptions = [ "--preview 'bat {}'" ];
    };
  };
}
