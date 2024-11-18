{ charts, ... }:
{
  nixidy.resourceImports = [
    ../crd/cilium.nix
  ];

  applications.cilium = {
    namespace = "kube-system";

    compareOptions.serverSideDiff = true;

    helm.releases.cilium = {
      chart = charts.cilium.cilium;

      values = {
        operator.replicas = 1;

        # # FIX: https://github.com/cilium/cilium/issues/31197
        # dnsProxy.enableTransparentMode = false;

        # replicate k3s environment
        ipam = {
          operator.clusterPoolIPv4PodCIDRList = [ "10.42.0.0/16" ];
        };

        # TODO: is host dependent: should come as modul option
        k8sServiceHost = "192.168.178.53";
        k8sServicePort = 6443;

        kubeProxyReplacement = true;

        policyEnforcementMode = "always";

        hubble = {
          relay.enabled = true;
          ui.enabled = true;
          tls.auto.method = "cronJob";
        };
      };
    };

    resources = {
      ciliumNetworkPolicies = {
        allow-coredns-apiserver-egress.spec = {
          endpointSelector.matchLabels.k8s-app = "kube-dns";
          egress = [
            {
              toEntities = [ "kube-apiserver" ];
            }
          ];
        };

        allow-hubble-relay-server-egress.spec = {
          endpointSelector.matchLabels."app.kubernetes.io/name" = "hubble-relay";
          egress = [
            {
              toEntities = [ "remote-node" "host" ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "4244";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
        };

        allow-hubble-ui-relay-ingress.spec = {
          endpointSelector.matchLabels."app.kubernetes.io/name" = "hubble-relay";
          ingress = [
            {
              fromEndpoints = [
                {
                  matchLabels."app.kubernetes.io/name" = "hubble-ui";
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "4245";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
        };

        allow-hubble-ui-kube-apiserver-egress.spec = {
          endpointSelector.matchLabels."app.kubernetes.io/name" = "hubble-ui";
          egress = [
            {
              toEntities = [ "kube-apiserver" ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "6443";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
        };

        allow-kube-dns-upstream-egress.spec = {
          endpointSelector.matchLabels.k8s-app = "kube-dns";
          egress = [
            {
              toEntities = [ "world" ];
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

        allow-hubble-generate-certs-apiserver-egress.spec = {
          endpointSelector.matchLabels."batch.kubernetes.io/job-name" = "hubble-generate-certs";
          egress = [
            {
              toEntities = [ "kube-apiserver" ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "6443";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };

      ciliumClusterwideNetworkPolicies = {
        allow-kube-dns-cluster-ingress.spec = {
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
      };
    };
  };
}
