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
    nushell
  ];

  home.file.".config/nushell/config.nu".source = ./nushell-config.nu;
  home.file.".config/nushell/env.nu".source = ./nushell-env.nu;
}
