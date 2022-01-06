{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lf
    wezterm
  ];

  imports = [
    ../shared/clamav.nix
  ];
}
