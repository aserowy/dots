{ ... }:
{
  imports = [
    ../shared/base.nix

    ./disko.nix
    ./hardware-configuration.nix
    ./homelab.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "homelab-01-nuc";

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager = {
      enable = true;
      insertNameservers = [ "127.0.0.1" ];
    };
  };

  services = {
    # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
    fstrim.enable = true;
    resolved.enable = false;
  };

  system = {
    # Did you read the comment?
    stateVersion = "24.05";
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      networkConfig.DHCP = "ipv4";
    };
  };
}
