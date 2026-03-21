{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.console;
in
{
  options.home.modules.console.enable = mkEnableOption "console";

  config = mkIf cnfg.enable {
    home = {
      components = {
        git.enable = true;
        opencode.enable = true;
        television.enable = true;
        zellij.enable = true;
      };

      modules = {
        neocode.enable = true;
        nushell.enable = true;
      };

      packages = with pkgs; [
        bat
        bottom
        curl
        fd
        lazygit
        yeet

        unixtools.watch
      ];
    };
  };
}
