{ pkgs, ... }:
{
  imports = [
    ../shared/base.nix

    ./hardware-configuration.nix

    ./borgbackup.nix
    ./fan-pwm.nix
    ./hassio.nix
    ./telegraf.nix
  ];

  environment.systemPackages = with pkgs; [
    neovim
  ];

  networking = {
    firewall = {
      allowPing = false;
      allowedTCPPorts = [
        80
        443
        2022
      ];
      allowedUDPPorts = [ 53 ];
    };

    hostName = "homeassistant";

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager = {
      enable = true;
      insertNameservers = [ "127.0.0.1" ];
    };
  };

  services.resolved.enable = false;

  system = {
    # Did you read the comment?
    stateVersion = "21.05";
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "ipv4";
      };
      "15-wlan" = {
        matchConfig.Name = "wlan0";
        networkConfig.DHCP = "ipv4";
      };
    };
    wait-online.ignoredInterfaces = [ "eth0" ];
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
}
