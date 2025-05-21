{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      chrome.enable = true;
      docker.enable = true;
      ghostty.enable = true;
      onedrive.enable = true;
      wpaperd.enable = true;

      # NOTE: fallback terminal
      kitty.enable = true;
    };

    modules = {
      console.enable = true;
      gaming.enable = true;
      gtk.enable = true;
      niri.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      discord
      drawio
      nautilus
      onlyoffice-desktopeditors
      spotify
    ];
  };
}
