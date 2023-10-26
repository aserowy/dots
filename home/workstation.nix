{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    components = {
      docker.enable = true;
      dunst.enable = true;
      onedrive.enable = true;
      swww.enable = true;
    };

    modules = {
      gtk.enable = true;
      hyprland.enable = true;
      teams.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      ardour
      discord
      gparted
      lutris
      obsidian
      remmina
      spotify
    ];
  };
}
