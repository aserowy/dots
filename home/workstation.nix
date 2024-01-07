{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      chrome.enable = true;
      docker.enable = true;
      foot.enable = true;
      obsidian.enable = true;
      onedrive.enable = true;
      swww.enable = true;

      # NOTE: for testing purposes
      yazi.enable = true;
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
      spotify
    ];
  };
}
