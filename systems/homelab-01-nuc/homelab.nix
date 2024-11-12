{
  config,
  lib,
  pkgs,
  ...
}:
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
        4240
        6443
        8080
      ];
      allowedUDPPorts = [
        8472
      ];
      trustedInterfaces = [
        "cilium_host"
        "cilium_net"
        "cilium_vxlan"
      ];
    };
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
      # tokenFile = config.sops.secrets."k3s/cluster/token".path;
      extraFlags =
        let
          # admissionControlConfig = pkgs.writeText "k3s-admission-control-config.yaml" ''
          #   apiVersion: apiserver.config.k8s.io/v1
          #   kind: AdmissionConfiguration
          #   plugins:
          #   - name: PodSecurity
          #     configuration:
          #       apiVersion: pod-security.admission.config.k8s.io/v1beta1
          #       kind: PodSecurityConfiguration
          #       defaults:
          #         enforce: "baseline"
          #         enforce-version: "latest"
          #         audit: "restricted"
          #         audit-version: "latest"
          #         warn: "restricted"
          #         warn-version: "latest"
          #       exemptions:
          #         usernames: []
          #         runtimeClasses: []
          #         namespaces: [kube-system]
          # '';
          #
          serverConfig = pkgs.writeText "k3s-config.yaml" (
            lib.generators.toYAML { } {
              #??? advertise-address = "192.168.178.53";

              cluster-init = true;
              # write-kubeconfig-mode = "0644";

              # use persisted data directory
              # data-dir = "/nix/persist/var/lib/rancher/k3s";

              # instead cilium will be deployed
              flannel-backend = "none";
              # disable-cloud-controller = true;
              disable-kube-proxy = true;
              disable-network-policy = true;
              # disable-helm-controller = true;

              disable = [
                "traefik"
                "servicelb"
                #   "local-storage"
                "metrics-server"
              ];

              # kube-apiserver-arg = [
              #   "admission-control-config-file=${admissionControlConfig}"
              #   "anonymous-auth=true"
              # ];
            }
          );
        in
        "--config ${serverConfig}";
    };

    # NOTE: is used by longhorn
    # openiscsi = {
    #   enable = true;
    # name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
    #   name = "iqn.2016-04.com.open-iscsi:homelab-01-nuc";
    # };
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
