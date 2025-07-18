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
    hostName = "homelab-02-l430";
    network = {
      adapter = "enp12s0";
      address = "192.168.178.202/24";
      gateway = "192.168.178.1";
    };
    cluster = {
      isAgentNode = true;
      masterAddress = "https://192.168.178.201:6443";
    };
  };

  # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
  services = {
    fstrim.enable = true;

    logind = {
      lidSwitch = "ignore";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
      extraConfig = ''
        IdleAction=ignore
        HandlePowerKey=ignore
        HandleSuspendKey=ignore
      '';
    };
  };

  system = {
    # Did you read the comment?
    stateVersion = "24.05";
  };
}
