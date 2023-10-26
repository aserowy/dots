{ ... }:
{
  imports = [
    ./components
    ./modules
  ];

  home = {
    stateVersion = "23.11";

    components = {
      fzf.enable = true;
      git.enable = true;
      lf.enable = true;
      nushell.enable = true;
      ssh.enable = true;
      wezterm.enable = true;
    };

    modules = {
      neovim.enable = true;
    };
  };
}
