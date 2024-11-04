{ config, ... }:
{
  # FIX: for longhorn on nixos
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  networking = {
    firewall = {
      allowedTCPPorts = [
        22
        80
        443
        6443 # k3s: required so that pods can reach the API server
      ];
      allowedUDPPorts = [
        8472 # k3s, flannel: required if using multi-node for inter-node networking
      ];
    };
  };

  services = {
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
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/root/.config/sops/age/homelab_keys.txt";

    secrets = {
      "root/password" = {
        neededForUsers = true;
      };
      "k3s/cluster/token" = { };
    };
  };
}
