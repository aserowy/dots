{ pkgs, ... }:
{
  imports = [
    ../modules/sway
    ./base.nix
  ];

  home = {
    modules = {
      docker.enable = true;
      gtk.enable = true;
      onedrive.enable = true;
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
