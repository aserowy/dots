{ config, lib, pkgs, ... }:
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
        gitui.enable = true;
        ssh.enable = true;
        yazi.enable = true;
      };

      modules = {
        neocode.enable = true;
        nushell.enable = true;
      };

      packages = with pkgs; [
        bat
        bottom
        broot
        curl
        gh
        # TODO: add component for lazygit
        lazygit
        ncurses
        tailspin
        tree
        yeet

        unixtools.watch
      ];
    };
  };
}
