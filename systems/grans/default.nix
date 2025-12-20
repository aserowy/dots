{ lib, ... }:
{
  imports = [
    ../shared/plasma.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "grans";

    interfaces = {
      enp0s31f6.useDHCP = lib.mkDefault true;
      wlan0.useDHCP = lib.mkDefault true;
    };
  };

  services = {
    clamav.daemon.settings.ExcludePath = "^/home/gran/.local/share/Steam\nExcludePath ^/home/gran/.steam";

    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;
  };
}
