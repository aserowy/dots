{ config, pkgs, ... }:
{
  home.file.".config/tmux/plugins/" = {
    source = ./tmux/plugins;
  };

  home.file.".tmux.conf" = {
    source = ./tmux/tmux.conf;
  };

  home.packages = with pkgs; [
    pkgs.python3Minimal
    pkgs.tmux
  ];
}

