{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.collabora = {
      chart = charts.collabora-online.collabora-online;

      values = {
        # NOTE: without dynamic load hpa is not necessary
        autoscaling.enabled = false;
        replicaCount = 1;
        collabora = {
          aliasgroups = [
            { host = "https://nextcloud.anderwerse.de:443"; }
          ];
          extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
          existingSecret = {
            enabled = true;
            secretName = "collabora";
          };
          proofKeysSecretRef = "collabora-proof-key";
        };
        podLabels = {
          "app.kubernetes.io/component" = "app";
          "haproxy/ingress" = "allow";
        };
        resources.requests = {
          cpu = "500m";
          memory = "2Gi";
        };
      };
    };

    resources = {
      ingresses.collabora = {
        metadata = {
          inherit namespace;
          annotations = {
            "cert-manager.io/cluster-issuer" = "azure-acme-issuer";
            "haproxy.org/timeout-tunnel" = "3600s";
            "haproxy.org/backend-config-snippet" =
              "balance url_param WOPISrc check_post
               hash-type consistent";
          };
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "collabora.anderwerse.de" ];
              secretName = "collabora-tls";
            }
          ];
          rules = [
            {
              host = "collabora.anderwerse.de";
              http.paths = [
                {
                  pathType = "ImplementationSpecific";
                  path = "/";
                  backend.service = {
                    name = "collabora-collabora-online";
                    port.number = 9980;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies.collabora = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector.matchLabels."app.kubernetes.io/name" = "collabora-collabora-online";
          ingress = [
            # NOTE: combining fromEndpoints and fromEntities is not supported
            {
              fromEntities = [ "host" ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "9980";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              fromEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "haproxy";
                    "app.kubernetes.io/name" = "kubernetes-ingress";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "9980";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
          egress = [
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "kube-system";
                    "k8s-app" = "kube-dns";
                  };
                }
              ];
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
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "haproxy";
                    "app.kubernetes.io/name" = "kubernetes-ingress";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "443";
                      protocol = "TCP";
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
