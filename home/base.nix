{ ... }:
{
  imports = [
    ./components
    ./modules
  ];

  home = {
    stateVersion = "23.11";

    components = {
      alacritty.enable = true;
    };

    modules = {
      console.enable = true;
    };
  };
}
