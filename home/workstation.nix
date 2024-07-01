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
      swww.enable = true;

      # NOTE: fallback terminal
      foot.enable = true;
    };

    modules = {
      gtk.enable = true;
      niri.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      drawio
      (lutris.override {
        extraPkgs = pkgs: [
          winePackages.staging
          wine64Packages.staging
        ];
      })
      obsidian
      remmina
      spotify
      xboxdrv
    ];
  };
}
