{ ... }:
{
  imports = [
    ../modules/sway
    ./base.nix
  ];

  home.modules.docker.enable = true;
}
