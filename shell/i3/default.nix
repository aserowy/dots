{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lf
    pavucontrol
    wezterm
    xclip
  ];

  imports = [
    ../shared/alacritty.nix
    ../shared/clamav.nix
    ../shared/dunst.nix
    ../shared/edge.nix
    ../shared/gtk.nix
    ../shared/lutris.nix
    ../shared/rofi
    ../shared/spotify.nix

    ./i3
    ./polybar
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

    # compose on right alt to be able to write äöüß
    xserver.xkbOptions = "compose:ralt";
  };
}
