{ ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      docker.enable = true;
      tmux.enable = true;
    };

    modules = {
      neovim.parallelTsBuild = false;
    };
  };
}
