{ config, pkgs, ... }:
{
  home.file.".config/tmux/plugins/tmux-continuum/" = {
    recursive = true;
    source = pkgs.sources.tmux-continuum.src;
  };

  home.file.".config/tmux/plugins/tmux-easy-motion/" = {
    recursive = true;
    source = pkgs.sources.tmux-easy-motion.src;
  };

  home.file.".config/tmux/plugins/tmux-resurrect/" = {
    recursive = true;
    source = pkgs.sources.tmux-resurrect.src;
  };

  home.file.".tmux.conf" = {
    source = ./tmux.conf;
  };

  home.packages = with pkgs; [
    pkgs.python3Minimal
    pkgs.tmux
  ];
}

