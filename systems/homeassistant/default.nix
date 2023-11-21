{ ... }:
{
  imports = [
    ../shared/base.nix

    ./hardware-configuration.nix

    ./borgbackup.nix
    ./fan-pwm.nix
    ./hassio.nix
    ./telegraf.nix
  ];

  boot.loader.raspberryPi.firmwareConfig = "dtparam=sd_poll_once=on";

  networking = {
    hostName = "homeassistant";

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager = {
      enable = true;
      insertNameservers = [ "127.0.0.1" ];
    };
  };

  services.resolved.enable = false;

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
}
