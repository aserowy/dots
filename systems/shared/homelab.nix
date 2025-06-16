{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.homelab;
in
{
  options.homelab = {
    enable = mkEnableOption "homelab";

    hostName = mkOption {
      type = types.str;
      description = ''
        Specify the hostname for the homelab. This is required to set up your system properly.
      '';
    };

    network = {
      adapter = mkOption {
        type = types.str;
        description = ''
          Specify the network adapter for the homelab. This is required to configure the networking correctly.
        '';
      };

      address = mkOption {
        type = types.str;
        description = ''
          Specify the host address for the homelab. E.g. "192.168.0.100/32". This is required to ensure proper networking.
        '';
      };

      gateway = mkOption {
        type = types.str;
        description = ''
          Specify the default gateway for the homelab network. This is required for proper routing.
        '';
      };
    };

    cluster.masterAddress = mkOption {
      type = types.str;
      default = "";
      description = ''
        Specify the master node address for the cluster and configure the node as agent.
      '';
    };
  };

  config = mkIf cnfg.enable {
    networking = {
      hostName = cnfg.hostName;
      firewall = {
        checkReversePath = "loose";
        interfaces."${cnfg.network.adapter}" = {
          allowedTCPPorts = [
            22
            6443
            6444
            9000
          ];
        };
        trustedInterfaces = [
          "cilium_host"
          "cilium_net"
          "cilium_vxlan"
          "lxc*"
        ];
      };
    };

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      # NOTE: longhorn requirement
      supportedFilesystems = [ "nfs" ];
    };

    # NOTE: longhorn requirement
    environment.systemPackages = with pkgs; [
      cryptsetup
      nfs-utils
    ];

    services = {
      # NOTE: longhorn requirement
      nfs.server.enable = true;
      rpcbind.enable = true;

      openiscsi = {
        enable = true;
        name = "iqn.2025-03.com.open-iscsi:${config.networking.hostName}";
      };

      k3s = {
        enable = true;

        clusterInit = cnfg.cluster.masterAddress == "";
        serverAddr = cnfg.cluster.masterAddress;

        tokenFile = config.sops.secrets."k3s/cluster/token".path;
        extraFlags =
          let
            serverConfig = pkgs.writeText "k3s-config.yaml" (
              lib.generators.toYAML { } {
                # NOTE: instead cilium will be deployed
                flannel-backend = "none";
                disable-cloud-controller = true;
                disable-kube-proxy = true;
                disable-network-policy = true;

                disable = [
                  "local-storage"
                  "metrics-server"
                  "servicelb"
                  "traefik"
                ];

                egress-selector-mode = "cluster";

                kube-apiserver-arg = [
                  "anonymous-auth=true"
                ];
              }
            );
          in
          "--config ${serverConfig}";
      };
    };

    systemd.network = {
      enable = true;
      networks = {
        "10-lan" = {
          matchConfig.Name = cnfg.network.adapter;
          address = [ cnfg.network.address ];
          gateway = [ cnfg.network.gateway ];
          dns = [
            "1.1.1.1"
            "8.8.4.4"
            "8.8.8.8"
          ];
        };
      };
    };
  };
}
