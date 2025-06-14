{ ... }:
{
  imports = [
    ../shared/base.nix
    ../shared/homelab.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "homelab-02-l430";

  services = {
    # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
    fstrim.enable = true;
  };

  system = {
    # Did you read the comment?
    stateVersion = "24.05";
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "eno1";
        networkConfig.DHCP = "ipv4";
        dns = [
          "1.1.1.1"
          "8.8.4.4"
          "8.8.8.8"
        ];
      };
    };
  };
}
