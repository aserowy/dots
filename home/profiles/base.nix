{ ... }:
{
  imports = [
    ../modules
  ];

  home.modules = {
    fzf.enable = true;
    git.enable = true;
    lf.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    wezterm.enable = true;
  };
}
