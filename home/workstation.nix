{ noctalia, pkgs, ... }:
{
  imports = [
    noctalia.homeModules.default

    ./base.nix
  ];

  home = {
    components = {
      bitwarden.enable = true;
      ghostty.enable = true;
      onedrive.enable = true;

      # NOTE: fallback terminal
      kitty.enable = true;
    };

    modules = {
      console.enable = true;
      gaming.enable = true;
      gtk.enable = true;
      noctalia.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      discord
      drawio
      nautilus
      onlyoffice-desktopeditors
      reaper
      rustdesk-flutter
      spotify
    ];
  };
}
