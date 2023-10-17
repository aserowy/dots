{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    modules = {
      docker.enable = true;
      dunst = {
        enable = true;
        enableSwayIntegration = true;
        enableHyprlandIntegration = true;
      };
      grimshot.enable = true;
      gtk.enable = true;
      hyprland.enable = true;
      lutris.enable = true;
      onedrive.enable = true;
      sway.enable = true;
      swww = {
        enable = true;
        enableSwayIntegration = true;
        enableHyprlandIntegration = true;
      };
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
