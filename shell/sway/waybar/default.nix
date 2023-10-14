{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    playerctl
    waybar
  ];

  environment.etc."xdg/waybar".source = ./src;
}
