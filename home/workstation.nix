{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      alacritty.enable = true;
      chrome.enable = true;
      docker.enable = true;
      logseq.enable = true;
      onedrive.enable = true;
      wpaperd.enable = true;

      # NOTE: fallback terminal
      kitty.enable = true;
    };

    modules = {
      gaming.enable = true;
      gtk.enable = true;
      niri.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      drawio
            gephi
      spotify
    ];
  };
}
