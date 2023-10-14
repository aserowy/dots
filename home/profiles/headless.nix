{ ... }:
{
  imports = [
    ../modules
    ../modules/headless
  ];

  config.home = {
    fzf.enable = true;
    neovim.enable = true;
  };
}
