{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bottles-unwrapped
    lutris
  ];

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';
}
