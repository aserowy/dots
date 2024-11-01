{ ... }:
{
  imports = [
    ../shared/base.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "homelab01";

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager = {
      enable = true;
      insertNameservers = [ "127.0.0.1" ];
    };
  };

  services.resolved.enable = false;

  services = {
    # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
    fstrim.enable = true;
  };

  system = {
    # Did you read the comment?
    stateVersion = "21.05";
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      networkConfig.DHCP = "ipv4";
    };
  };
}
