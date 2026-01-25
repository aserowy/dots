{ charts, ... }:
let
  namespace = "kube-system";
in
{
  applications.cilium = {
    inherit namespace;

    compareOptions.serverSideDiff = true;

    helm.releases.cilium = {
      chart = charts.cilium.cilium;

      values = {
        operator.replicas = 2;

        # NOTE: replicate k3s environment
        ipam.operator.clusterPoolIPv4PodCIDRList = [ "10.42.0.0/16" ];

        # TODO: is host dependent: should come as modul option
        k8sServiceHost = "192.168.178.201";
        k8sServicePort = 6443;

        kubeProxyReplacement = true;

        policyEnforcementMode = "default";

        # NOTE: mtls with spiffe
        authentication.mutual.spire = {
          enabled = false;
          install.server.dataStorage.storageClass = "longhorn-nobackup";
        };

        hubble = {
          relay.enabled = true;
          ui.enabled = true;
          tls.auto.method = "cronJob";
        };
      };
    };

    resources = {
      ciliumLoadBalancerIPPools.default-loadbalancer-ippool.spec = {
        # TODO: cidr configurable
        blocks = [ { cidr = "192.168.178.201/32"; } ];
        serviceSelector.matchLabels = {
          "app.kubernetes.io/role" = "entrypoint";
        };
      };

      ingresses.hubble = {
        metadata = {
          inherit namespace;
          annotations = {
            "cert-manager.io/cluster-issuer" = "azure-acme-issuer";
          };
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "hubble.cluster.anderwerse.de" ];
              secretName = "hubble-tls";
            }
          ];
          rules = [
            {
              host = "hubble.cluster.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "hubble";
                    port.number = 80;
                  };
                }
              ];
            }
          ];
        };
      };

      # TODO: remove after traefik migration
      certificates.hubble-tls-certificate.spec = {
        secretName = "hubble-tls-certificate";
        issuerRef = {
          name = "azure-acme-issuer";
          kind = "ClusterIssuer";
        };
        duration = "2160h";
        renewBefore = "720h";
        dnsNames = [
          "hubble.cluster.anderwerse.de"
        ];
      };

      # TODO: remove after traefik migration
      ingressRoutes.cilium-dashboard-route.spec = {
        entryPoints = [
          "websecure"
        ];
        routes = [
          {
            match = "Host(`hubble.cluster.anderwerse.de`)";
            kind = "Rule";
            services = [
              {
                name = "hubble-ui";
                namespace = "kube-system";
                port = 80;
              }
            ];
          }
        ];
        tls.secretName = "hubble-tls-certificate";
      };
    };
  };
}
