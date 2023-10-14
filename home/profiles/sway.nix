{ ... }:
{
  imports = [
    ../modules
    ../modules/headless
    ../modules/sway
  ];

  config.home = {
    fzf.enable = true;
    neovim.enable = true;
  };
}
