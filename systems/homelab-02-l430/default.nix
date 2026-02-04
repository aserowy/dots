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
      # NOTE: solar wlan forces 202... WTH
      address = "192.168.178.205/24";
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

    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "ignore";
      HandleSuspendKey = "ignore";
      IdleAction = "ignore";
    };
  };

  system = {
    # Did you read the comment?
    stateVersion = "24.05";
  };
}
