{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lf
    smartmontools
    wezterm
  ];

  programs.ssh = { 
    askPassword = "${pkgs.systemd}/bin/systemd-ask-password";
    enableAskPassword = true;
  };
}
