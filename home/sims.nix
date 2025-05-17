{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      chrome = {
        enable = true;
        setDefaultBrowserSessionVariable = true;
      };
      ghostty.enable = true;
    };

    modules = {
      gaming.enable = true;
    };

    packages = with pkgs; [
      kdePackages.plasma-browser-integration
      discord
      drawio
      gimp-with-plugins
      insync
      onlyoffice-desktopeditors
      spotify
    ];
  };
}
