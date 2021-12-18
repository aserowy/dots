{ config, pkgs, ... }:
{
  programs.mcfly = {
    enable = true;
    enableZshIntegration = true;
    keyScheme = "vim";
  };

  programs.zsh = {
    initExtra = ''
      eval bindkey "^r" mcfly-history-widget
    '';
  };
}
