{ pkgs, ... }:
{
  imports = [
    ../modules
  ];

  config.home = {
    fzf.enable = true;
    neovim.enable = true;
    nushell.enable = true;
  };
}
