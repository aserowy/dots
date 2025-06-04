{ charts, ... }:
{
  applications.cilium = {
    namespace = "kube-system";

    compareOptions.serverSideDiff = true;

    helm.releases.cilium = {
      chart = charts.cilium.cilium;

      values = {
        operator.replicas = 1;

        dnsProxy.enableTransparentMode = false;

        # replicate k3s environment
        ipam.operator.clusterPoolIPv4PodCIDRList = [ "10.42.0.0/16" ];

        # TODO: is host dependent: should come as modul option
        k8sServiceHost = "192.168.178.53";
        k8sServicePort = 6443;

        kubeProxyReplacement = true;

        policyEnforcementMode = "default";

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
          blocks = [ { cidr = "192.168.178.53/32"; } ];
          serviceSelector.matchLabels = {
            "homelab/loadbalancer" = "entrypoint";
          };
        };
      };
      ingressRoutes = {
        cilium-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`hubble.anderwerse.de`)";
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
          tls.secretName = "anderwersede-tls-certificate";
        };
      };
    };
  };
}
