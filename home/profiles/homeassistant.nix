{ ... }:
{
  imports = [
    ./base.nix
  ];

  home.modules.docker.enable = true;
}
