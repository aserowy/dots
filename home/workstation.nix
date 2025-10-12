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
      rustdesk
      spotify
    ];
  };

  xdg.desktopEntries = {
    "RustDesk (patched)" = {
      name = "RustDesk (patched)";
      icon = "rustdesk";
      genericName = "Remote Desktop";
      exec = "env GDK_BACKEND=x11 ${pkgs.rustdesk}/bin/rustdesk";
      terminal = false;
    };
  };
}
