{ ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      docker.enable = true;
    };

    modules = {
      neocode.parallelTsBuild = false;
    };
  };
}
