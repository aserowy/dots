{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ardour
    gparted
    remmina
    teams
  ];

  imports = [
    ../shared/gtk.nix
    ../shared/onedrive.nix
    ../shared/vscode.nix
  ];

  home.file.".config/i3/config" = {
    text = ''
      include /etc/i3/config
    '';
  };
}
