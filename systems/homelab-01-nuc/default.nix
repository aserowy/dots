{ config, ... }:
{
  imports = [
    ../shared/base.nix

    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # FIX: for longhorn on nixos
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  networking = {
    hostName = "homelab-01-nuc";

    # enables wifi with: nmcli device wifi connect <SSID> password <PASS>
    networkmanager = {
      enable = true;
      insertNameservers = [ "127.0.0.1" ];
    };

    firewall = {
      allowedTCPPorts = [
                80 443
        6443 # k3s: required so that pods can reach the API server
      ];
      allowedUDPPorts = [
        8472 # k3s, flannel: required if using multi-node for inter-node networking
      ];
    };
  };

  services = {
    # lsblk --discard to ensure ssd supports trim (disc-gran and disc-max should be non zero)
    fstrim.enable = true;

    k3s = {
      enable = true;
      role = "server";
      tokenFile = config.sops.secrets."k3s/cluster/token".path;
      extraFlags = toString ([
        "--write-kubeconfig-mode \"0644\""
        "--cluster-init"
        "--disable servicelb"
        "--disable traefik"
        "--disable local-storage"
        # ] ++ (if meta.hostname == "homelab-0" then [
        # ] else [
        #   "--server https://homelab-01-nuc:6443"
        # ]));
      ]);
      # NOTE: meta comes from https://github.com/dreamsofautonomy/homelab/blob/main/nixos/flake.nix
      # clusterInit = (meta.hostname == "homelab-0");
      clusterInit = true;
    };

    # NOTE: is used by longhorn
    openiscsi = {
      enable = true;
      # name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
      name = "iqn.2016-04.com.open-iscsi:homelab-01-nuc";
    };

    resolved.enable = false;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/homelab_keys.txt";

    secrets."k3s/cluster/token" = { };
  };

  system = {
    # Did you read the comment?
    stateVersion = "24.05";
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      networkConfig.DHCP = "ipv4";
    };
  };
}
