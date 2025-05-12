{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      ghostty.enable = true;
    };

    modules = {
      gaming.enable = true;
    };

    packages = with pkgs; [
      discord
      drawio
      gimp-with-plugins
      onlyoffice-desktopeditors
      spotify
    ];
  };
}
