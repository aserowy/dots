{ lib, ... }:
{
  imports = [
    ../shared/plasma.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "sims";

    interfaces = {
      enp0s31f6.useDHCP = lib.mkDefault true;
      wlan0.useDHCP = lib.mkDefault true;
    };
  };

  services = {
    clamav.daemon.settings.ExcludePath = "^/home/sims/.local/share/Steam\nExcludePath ^/home/sims/.steam";

    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    xserver.videoDrivers = [ "nvidia" ];
  };
}
