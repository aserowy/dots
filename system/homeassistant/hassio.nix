{ config, pkgs, ... }:
{
  systemd.services.init-docker-ha-network = {
    description = "Create the network bridge ha-network for home-assistant.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in
      ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${dockercli} network ls | grep "ha-network" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create ha-network
        else
          echo "ha-network already exists in docker"
        fi
      '';
  };

  virtualisation.oci-containers.containers = {
    "mosquitto" = {
      image = "eclipse-mosquitto:latest";
      extraOptions = [
        "--network=ha-network"
      ];
      volumes = [
        "/srv/mosquitto/config:/mosquitto/config"
        "/srv/mosquitto/data:/mosquitto/data"
        "/srv/mosquitto/log:/mosquitto/log"
      ];
    };

    "zigbee2mqtt" = {
      image = "koenkk/zigbee2mqtt:latest";
      environment = {
        "TZ" = "Europe/Berlin";
      };
      dependsOn = [
        "mosquitto"
      ];
      extraOptions = [
        "--network=ha-network"
        "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0"
      ];
      ports = [
        "8124:8080"
      ];
      volumes = [
        "/srv/zigbee2mqtt:/app/data"
        "/run/udev:/run/udev:ro"
      ];
    };

    "home-assistant" = {
      image = "homeassistant/home-assistant:stable";
      extraOptions = [
        "--network=ha-network"
        "--device=/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0:/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0"
      ];
      dependsOn = [
        "mosquitto"
      ];
      ports = [
        "80:8123"
        "8123:8123"
      ];
      volumes = [
        "/srv/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };
    "docker2mqtt" = {
      image = "serowy/docker2mqtt:latest";
      extraOptions = [
        "--network=ha-network"
      ];
      dependsOn = [
        "mosquitto"
      ];
      volumes = [
        "/srv/docker2mqtt/config:/docker2mqtt/config"
        "/srv/docker2mqtt/logs:/docker2mqtt/logs"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };

    "pihole" = {
      image = "pihole/pihole:latest";
      environment = {
        "TZ" = "Europe/Berlin";
        # Run docker logs pihole | grep random to find your random pass.
        # WEBPASSWORD: <pw>
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
      ];
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "67:67/udp"
        "8125:80/tcp"
      ];
      volumes = [
        "/srv/pihole/config/:/etc/pihole/"
        "/srv/pihole/dnsmasq.d/:/etc/dnsmasq.d/"
      ];
    };

    "watchtower" = {
      image = "containrrr/watchtower:latest";
      environment = {
        "WATCHTOWER_CLEANUP" = "true";
        "WATCHTOWER_INCLUDE_RESTARTING" = "true";
        "WATCHTOWER_INCLUDE_STOPPED" = "true";
        "WATCHTOWER_SCHEDULE" = "0 0 4 * * *";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
