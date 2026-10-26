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
    hostName = "homelab-06-l570";
    network = {
      adapter = "enp12s0";
      address = "192.168.178.207/24";
      gateway = "192.168.178.1";
    };
    cluster.masterAddress = "https://192.168.178.201:6443";
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
