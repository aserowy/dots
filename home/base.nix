{ ... }:
{
  imports = [
    ./components
    ./modules
  ];

  home = {
    stateVersion = "23.11";

    components = {
      wezterm.enable = true;
    };

    modules = {
      console.enable = true;
    };
  };
}
