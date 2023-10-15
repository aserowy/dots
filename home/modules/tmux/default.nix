{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.tmux;
in
{
  options.home.modules.tmux.enable = mkEnableOption "tmux";

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/tmux/plugins/tmux-continuum/" = {
          recursive = true;
          source = pkgs.sources.tmux-continuum.src;
        };

        ".config/tmux/plugins/tmux-easy-motion/" = {
          recursive = true;
          source = pkgs.sources.tmux-easy-motion.src;
        };

        ".config/tmux/plugins/tmux-resurrect/" = {
          recursive = true;
          source = pkgs.sources.tmux-resurrect.src;
        };

        ".tmux.conf" = {
          source = ./tmux.conf;
        };

      };

      packages = with pkgs; [
        python3Minimal
        tmux
      ];
    };
  };
}
