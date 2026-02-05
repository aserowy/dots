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
  serverRole = if cnfg.cluster.isAgentNode then "agent" else "server";
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
            2381 # etcd metrics
            4240 # cilium health checks
            4244 # Hubble server
            4245 # Hubble Relay
            4250 # Mutual Authentication port
            4251 # Spire Agent health check port (listening on 127.0.0.1 or ::1)
            6060 # cilium-agent pprof server (listening on 127.0.0.1)
            6061 # cilium-operator pprof server (listening on 127.0.0.1)
            6062 # Hubble Relay pprof server (listening on 127.0.0.1)
            6443 # kube api server
            9100 # node exporter metrics
            9878 # cilium-envoy health listener (listening on 127.0.0.1)
            9879 # cilium-agent health status API (listening on 127.0.0.1 and/or ::1)
            9890 # cilium-agent gops server (listening on 127.0.0.1)
            9891 # operator gops server (listening on 127.0.0.1)
            9893 # Hubble Relay gops server (listening on 127.0.0.1)
            9901 # cilium-envoy Admin API (listening on 127.0.0.1)
            9962 # cilium-agent Prometheus metrics
            9963 # cilium-operator Prometheus metrics
            9964 # cilium-envoy Prometheus metrics
            10250 # kubelet
            10259 # kube scheduler metrics
          ];
          allowedUDPPorts = [
            8472 # vxlan
            51871 # WireGuard encryption tunnel endpoint
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
        role = serverRole;
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
                  "servicelb"
                  "traefik"
                ];

                kube-apiserver-arg = [
                  "anonymous-auth=true"
                ];

                kube-scheduler-arg = [
                  "bind-address=0.0.0.0"
                ];

                etcd-expose-metrics = true;
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
