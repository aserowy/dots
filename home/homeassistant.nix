{ ... }:
{
  imports = [
    ./base.nix
  ];

  home.modules = {
    docker.enable = true;
    neovim.parallelTsBuild = false;
    tmux.enable = true;
  };
}
