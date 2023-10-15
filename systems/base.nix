{ pkgs, ... }:
{
  imports = [
    ./modules
  ];

  environment.systemPackages = with pkgs; [
    lf
    smartmontools
    wezterm
  ];
}
