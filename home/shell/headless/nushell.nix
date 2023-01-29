{ config, pkgs, lib, ... }:
{
  imports = [
    ./direnv.nix
    ./fzf.nix
    ./starship.nix
    ./zoxide.nix
  ];
    
  home.packages = with pkgs; [
    exa
  ];

  /*
    home.file.".config/nushell/config.nu".source = ./nushell-config.nu;
    home.file.".config/nushell/env.nu".source = ./nushell-env.nu;
  */

  programs.nushell = {
    enable = true;
    configFile.source = ./nushell-config.nu;
    envFile.source = ./nushell-env.nu;
  };
}
