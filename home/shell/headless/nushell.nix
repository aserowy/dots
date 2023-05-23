{ pkgs, ... }:
{
  imports = [
    ./direnv.nix
    ./fzf.nix
    ./starship.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    carapace
    exa
    nushell
  ];

  home = {
    file.".config/nushell/config.nu".source = ./nushell-config.nu;
    file.".config/nushell/env.nu".source = ./nushell-env.nu;
    file.".config/nushell/scripts".source = ./nushell;
  };
}
