{ config, ... }:
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

    # TODO: add subdomain to nginx with port 8086
    influxdb = {
      image = "influxdb:latest";
      extraOptions = [
        "--network=ha-network"
      ];
      volumes = [
        "/srv/influxdb:/var/lib/influxdb2"
        "/srv/influxdb/config.yml:/etc/influxdb2/config.yml"
      ];
    };

    grafana = {
      image = "grafana/grafana-oss:latest";
      user = "root";
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
    };

    home-assistant = {
      image = "homeassistant/home-assistant:stable";
      extraOptions = [
        "--network=ha-network"
        "--device=/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0:/dev/serial/by-id/usb-EnOcean_GmbH_EnOcean_USB_300_DC_FT50B8B0-if00-port0"
      ];
      dependsOn = [
        "influxdb"
        "mariadb"
        "mosquitto"
      ];
      volumes = [
        "/srv/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    pihole = {
      image = "pihole/pihole:latest";
      environment = {
        "TZ" = "Europe/Berlin";
        "CORS_HOSTS" = "dns.smart.home";
        "DNSMASQ_USER" = "root";
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--dns=127.0.0.1"
        "--network=ha-network"
      ];
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "67:67/udp"
      ];
      volumes = [
        "/srv/pihole/config/:/etc/pihole/"
        "/srv/pihole/dnsmasq.d/:/etc/dnsmasq.d/"
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
