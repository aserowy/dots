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

  users.groups.service-restricted = {};

  users.users = {
    service-mosquitto = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-zigbee = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-mariadb = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-influxdb = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-grafana = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-hassio = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-docker = {
      isSystemUser = true;
      group = "service-restricted";
      extraGroups = [
        "docker"
      ];
    };
    service-pihole = {
      isSystemUser = true;
      group = "service-restricted";
    };
    service-watchtower = {
      isSystemUser = true;
      group = "service-restricted";
      extraGroups = [
        "docker"
      ];
    };
  };

  virtualisation.oci-containers.containers = {
    "mosquitto" = {
      image = "eclipse-mosquitto:latest";
      user = "service-mosquitto";
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
      user = "service-zigbee";
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

    "mariadb" = {
      image = "mariadb:latest";
      user = "service-mariadb";
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

    "influxdb" = {
      image = "influxdb:latest";
      extraOptions = [
        "--network=ha-network"
      ];
      ports = [
        "8127:8086"
      ];
      volumes = [
        "/srv/influxdb:/var/lib/influxdb2"
        "/srv/influxdb/config.yml:/etc/influxdb2/config.yml"
      ];
    };

    "grafana" = {
      image = "grafana/grafana-oss:latest";
      user = "service-grafana";
      environment = {
        "GF_PATHS_CONFIG" = "/var/lib/grafana/grafana.ini";
      };
      extraOptions = [
        "--network=ha-network"
      ];
      dependsOn = [
        "influxdb"
      ];
      volumes = [
        "/srv/grafana:/var/lib/grafana"
      ];
      ports = [
        "8126:3000"
      ];
    };

    "home-assistant" = {
      image = "homeassistant/home-assistant:stable";
      user = "service-hassio";
      extraOptions = [
        "--network=ha-network"
        "--device=/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0:/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0"
      ];
      dependsOn = [
        "influxdb"
        "mariadb"
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
      user = "service-docker";
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
      user = "service-pihole";
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
      user = "service-watchtower";
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
