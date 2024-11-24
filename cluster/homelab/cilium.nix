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
        ipam.operator.clusterPoolIPv4PodCIDRList = [ "10.42.0.0/16" ];

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
        # kube dns
        allow-kubedns-egress-kubeapiserver.spec = {
          endpointSelector.matchLabels.k8s-app = "kube-dns";
          egress = [
            {
              toEntities = [ "kube-apiserver" ];
            }
          ];
        };

        allow-kubedns-egress-world.spec = {
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

        # hubble
        allow-hubblerelay-egress-nodes.spec = {
          endpointSelector.matchLabels."app.kubernetes.io/name" = "hubble-relay";
          egress = [
            {
              toEntities = [
                "remote-node"
                "host"
              ];
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

        allow-hubblerelay-ingress-hubbleui.spec = {
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

        allow-hubbleui-egress-kubeapiserver.spec = {
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

        allow-hubblegeneratecerts-egress-kubeapiserver.spec = {
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
        # kube dns
        allow-kubedns-ingress-cluster.spec = {
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

        # health checks
        allow-health-bigress-nodes.spec = {
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

        # inter node
        allow-cluster-egress-cluster.spec = {
          endpointSelector = { };
          egress = [
            {
              toEndpoints = [ { } ];
            }
          ];
        };
      };
    };
  };
}
