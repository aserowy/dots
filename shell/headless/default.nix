{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lf
    smartmontools
    wezterm
  ];

  programs.ssh = {
    enableAskPassword = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = false;
  };
}
