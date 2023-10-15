{ pkgs, ... }:
{
  environment = {
    /* sets ozone wayland support for all chromium based applications */
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      clipman
      lf
      pavucontrol
      sway-contrib.grimshot
      wezterm
      wl-clipboard
    ];
  };

  imports = [
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
    packages = with pkgs; [
      powerline-fonts
      nerdfonts
    ];
  };
}
