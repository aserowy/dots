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
    hostName = "homelab-05-t540p";
    network = {
      adapter = "enp0s25";
      address = "192.168.178.206/24";
      gateway = "192.168.178.1";
    };
    cluster = {
      isAgentNode = true;
      masterAddress = "https://192.168.178.201:6443";
    };
    labels = {
      "hardware/ram" = "high";
    };
  };

  services = {
    # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
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
