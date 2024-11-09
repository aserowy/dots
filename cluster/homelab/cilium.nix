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
      ciliumNetworkPolicies = {
        # Allow hubble relay server egress to nodes
        allow-hubble-relay-server-egress.spec = {
          description = "Policy for egress from hubble relay to hubble server in Cilium agent.";
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

        # Allow hubble UI to talk to hubble relay
        allow-hubble-ui-relay-ingress.spec = {
          description = "Policy for ingress from hubble UI to hubble relay.";
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

        # Allow hubble UI to talk to kube-apiserver
        allow-hubble-ui-kube-apiserver-egress.spec = {
          description = "Allow Hubble UI to talk to kube-apiserver";
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

        # Allow kube-dns to talk to upstream DNS
        allow-kube-dns-upstream-egress.spec = {
          description = "Policy for egress to allow kube-dns to talk to upstream DNS.";
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

        # Allow CoreDNS to talk to kube-apiserver
        allow-kube-dns-apiserver-egress.spec = {
          description = "Allow coredns to talk to kube-apiserver.";
          endpointSelector.matchLabels.k8s-app = "kube-dns";
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

        # Allow hubble-generate-certs job to talk to kube-apiserver
        allow-hubble-generate-certs-apiserver-egress.spec = {
          description = "Allow hubble-generate-certs job to talk to kube-apiserver.";
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
        # Allow all cilium endpoints to talk egress to each other
        allow-internal-egress.spec = {
          description = "Policy to allow all Cilium managed endpoint to talk to all other cilium managed endpoints on egress";
          endpointSelector = { };
          egress = [
            {
              toEndpoints = [ { } ];
            }
          ];
        };

        # Allow all health checks
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

        # Allow all cilium managed endpoints to talk to cluster dns
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
