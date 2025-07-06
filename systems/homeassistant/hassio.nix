{ config, ... }:
{
  systemd.services.init-docker-ha-network = {
    description = "Create the network bridge ha-network for home-assistant.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script =
      let
        dockercli = "${config.virtualisation.docker.package}/bin/docker";
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
    nginx = {
      image = "nginx:latest";
      extraOptions = [
        "--network=ha-network"
      ];
      ports = [
        "80:80"
      ];
      volumes = [
        "/srv/nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro"
      ];
    };

    broker = {
      image = "valkey/valkey:latest";
      extraOptions = [
        "--network=ha-network"
      ];
      volumes = [
        "/srv/valkey/data:/data"
      ];
    };

    mosquitto = {
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

    zigbee2mqtt = {
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
      volumes = [
        "/srv/zigbee2mqtt:/app/data"
        "/run/udev:/run/udev:ro"
      ];
    };

    mariadb = {
      image = "mariadb:latest";
      environment = {
        "MARIADB_DATABASE" = "homeassistant";
        "MARIADB_USER" = "homeassistant";
        "MARIADB_PASSWORD_FILE" = "/var/lib/mysql/user_password";
        "MARIADB_ROOT_PASSWORD_FILE" = "/var/lib/mysql/root_password";
      };
      extraOptions = [
        "--network=ha-network"
      ];
      volumes = [
        "/srv/mariadb:/var/lib/mysql"
      ];
    };

    home-assistant = {
      image = "homeassistant/home-assistant:stable";
      extraOptions = [
        "--network=ha-network"
        "--device=/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0:/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0"
      ];
      dependsOn = [
        "mariadb"
        "mosquitto"
      ];
      volumes = [
        "/srv/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    watchtower = {
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
