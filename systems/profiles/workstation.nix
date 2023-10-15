{ ... }:
{
  imports = [
    ./base.nix
    ../modules/sway-old
  ];

  programs = {
    seahorse.enable = true;
    steam.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    onedrive.enable = true;
  };

  system.modules = {
    sway.enable = true;
  };
}
