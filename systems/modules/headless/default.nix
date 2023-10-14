{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lf
    smartmontools
    wezterm
  ];
}
