{ config, pkgs, ... }:
{
  imports = [
    ../base.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "desktop-workstation";
    interfaces.eno1.useDHCP = true;
  };

  services = {
    # lsblk --discard to ensure ssd supports trim
    # (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };

    xserver.videoDrivers = [ "nvidia" ];
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
}
