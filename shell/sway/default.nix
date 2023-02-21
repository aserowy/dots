{ config, pkgs, ... }:
{
  environment = {
    /* sets ozone wayland support for all chromium based applications */
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      bottles
      clipman
      lf
      pavucontrol
      sway-contrib.grimshot
      wezterm
      wl-clipboard
    ];
  };

  imports = [
    ../shared/alacritty.nix
    ../shared/clamav.nix
    ../shared/dunst.nix
    ../shared/edge.nix
    ../shared/gtk.nix
    ../shared/lutris.nix
    ../shared/rofi/rofi-wayland.nix
    ../shared/spotify.nix

    ./tuigreeter.nix
    ./sway
    ./waybar
  ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      powerline-fonts
      nerdfonts
    ];
  };

  programs = {
    seahorse.enable = true;
    steam.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;

    onedrive.enable = true;
  };
}
