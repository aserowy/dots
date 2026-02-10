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
        fzf.enable = true;
        git.enable = true;
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
        opencode
        yeet

        unixtools.watch
      ];
    };
  };
}
