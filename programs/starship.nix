{ config, pkgs, ... }:
{
  home.file.".config/starship.toml".source = ./starship.toml;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
