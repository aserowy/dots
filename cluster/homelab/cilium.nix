{ charts, ... }:
{
  nixidy.resourceImports = [
    ../cdr/cilium.nix
  ];

  applications.cilium = {
    namespace = "cilium";

    helm.releases.cilium = {
      chart = charts.cilium.cilium;

      values = {
        operator.replicas = 1;

        # replicate k3s environment.
        ipam.operator.clusterPoolIPv4PodCIDRList = [ "10.42.0.0/16" ];

        k8sServiceHost = "localhost";
        k8sServicePort = 6444;

        # policy enforcement.
        policyEnforcementMode = "always";
        policyAuditMode = false;

        # set cilium as a kube-proxy replacement.
        kubeProxyReplacement = true;

        hubble = {
          relay.enabled = true;
          ui.enabled = true;
          tls.auto.method = "cronJob";
        };
      };
    };

    resources = {
      ciliumClusterwideNetworkPolicies = {
        allow-internal-egress.spec = {
          description = "Policy to allow all Cilium managed endpoint to talk to all other cilium managed endpoints on egress";
          endpointSelector = { };
          egress = [
            {
              toEndpoints = [ { } ];
            }
          ];
        };

        cilium-health-checks.spec = {
          endpointSelector.matchLabels."reserved:health" = "";
          ingress = [
            {
              fromEntities = [ "remote-node" ];
            }
          ];
          egress = [
            {
              toEntities = [ "remote-node" ];
            }
          ];
        };

        allow-kube-dns-cluster-ingress.spec = {
          description = "Policy for ingress allow to kube-dns from all Cilium managed endpoints in the cluster.";
          endpointSelector.matchLabels = {
            "k8s:io.kubernetes.pod.namespace" = "kube-system";
            "k8s-app" = "kube-dns";
          };
          ingress = [
            {
              fromEndpoints = [ { } ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "53";
                      protocol = "UDP";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
