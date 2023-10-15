{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # waybar
      jq
      pavucontrol
      sway-contrib.grimshot
      swappy
    ];
  };

  imports = [
    ../shared/dunst.nix
    ../shared/edge.nix
    ../shared/gtk.nix
    ../shared/rofi/rofi-wayland.nix

    ./tuigreeter.nix
    ./waybar
  ];
}
