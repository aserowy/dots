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
          8080
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

  services = {
    k3s = {
      enable = true;
      clusterInit = true;
      tokenFile = config.sops.secrets."k3s/cluster/token".path;
      extraFlags =
        let
          admissionControlConfig = pkgs.writeText "k3s-admission-control-config.yaml" ''
            apiVersion: apiserver.config.k8s.io/v1
            kind: AdmissionConfiguration
            plugins:
            - name: PodSecurity
              configuration:
                apiVersion: pod-security.admission.config.k8s.io/v1beta1
                kind: PodSecurityConfiguration
                defaults:
                  enforce: "baseline"
                  enforce-version: "latest"
                  audit: "restricted"
                  audit-version: "latest"
                  warn: "restricted"
                  warn-version: "latest"
                exemptions:
                  usernames: []
                  runtimeClasses: []
                  namespaces: [kube-system]
          '';

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
                "admission-control-config-file=${admissionControlConfig}"
                "anonymous-auth=true"
              ];
            }
          );
        in
        "--config ${serverConfig}";
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
