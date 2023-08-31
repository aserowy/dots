{ pkgs, ... }:
{
  imports = [
    ../base.nix
    ../printing.nix

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

    # to enable working with qmk on this pc
    udev.packages = [ pkgs.qmk-udev-rules ];

    xserver.videoDrivers = [ "amdgpu" ];
  };

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:aserowy/dots";
      flags = [
        "--recreate-lock-file"
        "--no-write-lock-file"
        "-L"
      ];
      dates = "03:45";
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
}
