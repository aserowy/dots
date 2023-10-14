{ ... }:
{
  imports = [
    ../modules
  ];

  config.home = {
    fzf.enable = true;
    lf.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    wezterm.enable = true;
  };
}
