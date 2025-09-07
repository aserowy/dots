{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.homelab;
  isMasterNode = cnfg.cluster.masterAddress == "";
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

    cluster = {
      isAgentNode = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Determines if this node is an agent or controle plane.
        '';
      };

      masterAddress = mkOption {
        type = types.str;
        default = "";
        description = ''
          Specify the master node address for the cluster and configure the node as agent.
        '';
      };
    };
  };

  config = mkIf cnfg.enable {
    users.mutableUsers = false;

    networking = {
      hostName = cnfg.hostName;

      firewall = {
        checkReversePath = "loose";
        interfaces."${cnfg.network.adapter}" = {
          # TODO: remove ports used by trusted interfaces
          allowedTCPPorts = [
            22
            2379 # etcd client
            2380 # etcd peer
            6443 # kube api server
            10250 # kubelet
          ];
          allowedUDPPorts = [
            8472 # vxlan
          ];
        };
        trustedInterfaces = [
          "cilium_host"
          "cilium_net"
          "cilium_vxlan"
          "lxc*"
        ];
      };

      useNetworkd = true;
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

    security = {
      auditd.enable = true;
      audit.enable = true;
    };

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

        clusterInit = isMasterNode;
        role = mkIf cnfg.cluster.isAgentNode "agent";
        serverAddr = cnfg.cluster.masterAddress;

        tokenFile = config.sops.secrets."k3s/cluster/token".path;
        extraFlags = mkIf (!cnfg.cluster.isAgentNode) (
          let
            serverConfig = pkgs.writeText "k3s-config.yaml" (
              lib.generators.toYAML { } {
                # NOTE: instead cilium will be deployed
                flannel-backend = "none";
                disable-cloud-controller = true;
                disable-kube-proxy = true;
                disable-network-policy = true;

                cluster-cidr = "10.42.0.0/16";
                service-cidr = "10.43.0.0/16";

                disable = [
                  "local-storage"
                  "metrics-server"
                  "servicelb"
                  "traefik"
                ];

                kube-apiserver-arg = [
                  "anonymous-auth=true"
                ];
              }
            );
          in
          "--config ${serverConfig}"
        );
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
          ];
        };
      };
    };
  };
}
