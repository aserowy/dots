{ ... }:
{
  imports = [
    ../shared/base.nix
    ../shared/homelab.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  homelab = {
    enable = true;
    hostName = "homelab-01-nuc";
    network = {
      adapter = "eno1";
      address = "192.168.178.201/24";
      gateway = "192.168.178.1";
    };
  };

  # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
  services.fstrim.enable = true;

  system = {
    # Did you read the comment?
    stateVersion = "24.05";
  };
}
