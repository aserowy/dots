{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    firewall = {
      checkReversePath = "loose";
      interfaces.eno1 = {
        allowedTCPPorts = [
          22
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

  # NOTE: longhorn requirement
  boot.supportedFilesystems = [ "nfs" ];

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
      clusterInit = true;
      tokenFile = config.sops.secrets."k3s/cluster/token".path;
      extraFlags =
        let
          serverConfig = pkgs.writeText "k3s-config.yaml" (
            lib.generators.toYAML { } {
              # instead cilium will be deployed
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
}
