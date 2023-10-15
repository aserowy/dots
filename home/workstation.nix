{ pkgs, ... }:
{
  imports = [
    ./base.nix
  ];

  home = {
    modules = {
      docker.enable = true;
      grimshot.enable = true;
      gtk.enable = true;
      onedrive.enable = true;
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
    ];
  };
}
