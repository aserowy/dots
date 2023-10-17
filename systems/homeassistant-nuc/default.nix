{ ... }:
{
  imports = [
    ../shared/base.nix

    ./hardware-configuration.nix

    ../homeassistant/borgbackup.nix
    ../homeassistant/hassio.nix
    ../homeassistant/telegraf.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "homeassistant-nuc";
    interfaces.eno1.useDHCP = true;

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager.enable = true;
  };

  services = {
    # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
    fstrim.enable = true;
  };
}
