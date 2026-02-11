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
        l2announcements.enabled = true;
        policyEnforcementMode = "default";

        hubble = {
          relay.enabled = true;
          ui.enabled = true;
          tls.auto.method = "cronJob";
        };
      };
    };

    resources = {
      # NOTE: patch hubble ui deployment to enable labeled ingress in HAProxy
      deployments.hubble-ui.spec.template.metadata.labels."haproxy/egress" = "allow";

      ciliumL2AnnouncementPolicies.default.spec = {
        loadBalancerIPs = true;
        serviceSelector.matchLabels = {
          "cilium/l2" = "announce";
        };
        nodeSelector.matchExpressions = [
          {
            key = "node-role.kubernetes.io/control-plane";
            operator = "DoesNotExist";
          }
        ];
        interfaces = [
          "eno1"
          "enp0s25"
          "enp12s0"
        ];
      };

      ciliumLoadBalancerIPPools = {
        default-loadbalancer-ippool.spec = {
          # TODO: cidr configurable
          blocks = [ { cidr = "192.168.178.201/32"; } ];
          serviceSelector.matchLabels = {
            "cilium/ippool" = "default";
          };
        };
        dns-loadbalancer-ippool.spec = {
          blocks = [ { cidr = "192.168.178.230/32"; } ];
          serviceSelector.matchLabels = {
            "cilium/ippool" = "dns";
          };
        };
        haproxy-loadbalancer-ippool.spec = {
          blocks = [ { cidr = "192.168.178.231/32"; } ];
          serviceSelector.matchLabels = {
            "cilium/ippool" = "haproxy";
          };
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
                    name = "hubble-ui";
                    port.number = 80;
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
