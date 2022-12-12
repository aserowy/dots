{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lf
    smartmontools
    wezterm
  ];

  imports = [
    ../shared/clamav.nix
  ];

  programs.ssh = { 
    askPassword = "${pkgs.systemd}/bin/systemd-ask-password";
    enableAskPassword = true;
  };
}
