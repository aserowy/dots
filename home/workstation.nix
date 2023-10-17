{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    modules = {
      dunst = {
        enable = true;
        enableSwayIntegration = true;
      };
      lutris.enable = true;
      sway.enable = true;
      swww = {
        enable = true;
        enableSwayIntegration = true;
      };

      docker.enable = true;
      grimshot.enable = true;
      gtk.enable = true;
      onedrive.enable = true;
      # hyprland.enable = true;
      teams.enable = true;
      vscode.enable = true;
      xdg.enable = true;
    };

    packages = with pkgs; [
      ardour
      discord
      gparted
      obsidian
      remmina
      spotify
    ];
  };
}
