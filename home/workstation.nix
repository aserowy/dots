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

      # NOTE: fallback terminal
      foot.enable = true;

      obsidian.enable = true;
      onedrive.enable = true;
      swww.enable = true;
    };

    modules = {
      gtk.enable = true;
      hyprland.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      discord
      (lutris.override {
        extraPkgs = pkgs: [
          winePackages.staging
          wine64Packages.staging
        ];
      })
      remmina
      spotify
    ];
  };
}
