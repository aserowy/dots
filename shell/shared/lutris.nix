{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lutris
  ];

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';
}
