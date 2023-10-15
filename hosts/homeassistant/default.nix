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

    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
}
