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
        "fg" = "-1";
        "bg" = "-1";
        "hl" = "#c678dd";
        "fg+" = "#ffffff";
        "bg+" = "#4b5263";
        "hl+" = "#d858fe";
        "info" = "#98c379";
        "prompt" = "#61afef";
        "pointer" = "#be5046";
        "marker" = "#e5c07b";
        "spinner" = "#61afef";
        "header" = "#61afef";
      };
    };
  };
}
