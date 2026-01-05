{ lib, ... }:
{
  imports = [
    ../shared/plasma.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "musicstation";

    interfaces = {
      eno1.useDHCP = lib.mkDefault true;
      # wlan0.useDHCP = lib.mkDefault true;
    };
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  services = {
    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    xserver.videoDrivers = [ "nvidia" ];
  };
}
