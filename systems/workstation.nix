{ pkgs, ... }:
{
  imports = [
    ./base.nix
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


  # TODO: lutris specific, but unable to set with home manager?
  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';


  system.modules = {
    gtk.enable = true;
    tuigreet = {
      enable = true;
      command = "sway";
      # command = "Hyprland";
    };
  };
}
