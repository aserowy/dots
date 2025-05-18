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
      console.enable = true;
      neocode.parallelTsBuild = false;
    };
  };
}
