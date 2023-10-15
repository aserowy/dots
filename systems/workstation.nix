{ ... }:
{
  imports = [
    ./base.nix
    ./modules/sway-old
  ];

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
  };
}
