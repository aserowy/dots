{ ... }:
{
  imports = [
    ./components
    ./modules
  ];

  home = {
    stateVersion = "23.11";

    modules = {
      console.enable = true;
    };
  };
}
