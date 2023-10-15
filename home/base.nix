{ ... }:
{
  imports = [
    ./modules
  ];

  home = {
    stateVersion = "22.05";

    modules = {
      fzf.enable = true;
      git.enable = true;
      lf.enable = true;
      neovim.enable = true;
      nushell.enable = true;
      ssh.enable = true;
      vscode-server.enable = true;
      wezterm.enable = true;
    };
  };
}
