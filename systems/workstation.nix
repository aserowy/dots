{ pkgs, ... }:
{
  imports = [
    ./base.nix
    ./modules/sway-old
  ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      powerline-fonts
      nerdfonts
    ];
  };

  programs = {
    seahorse.enable = true;
    steam.enable = true;
  };

  services = {
    clamav = {
      updater.enable = true;

      daemon = {
        enable = true;
        settings = {
          ExcludePath = "^/home/serowy/games/";
        };
      };
    };

    gnome.gnome-keyring.enable = true;

    onedrive.enable = true;
  };

  system.modules = {
    lutris.enable = true;
    sway.enable = true;
    tuigreet.enable = true;
  };
}
