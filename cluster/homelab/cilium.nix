{ charts, ... }:
{
  applications.cilium = {
    namespace = "kube-system";

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
      ciliumLoadBalancerIPPools = {
        default-loadbalancer-ippool.spec = {
          # TODO: cidr configurable
          blocks = [ { cidr = "192.168.178.201/32"; } ];
          serviceSelector.matchLabels = {
            "app.kubernetes.io/role" = "entrypoint";
          };
        };
      };
    };
  };
}
