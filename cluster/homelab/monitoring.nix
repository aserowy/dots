{ charts, ... }:
let
  namespace = "monitoring";
in
{
  applications.monitoring = {
    inherit namespace;

    createNamespace = true;

    syncPolicy = {
      autoSync = {
        prune = false;
        selfHeal = false;
      };
      syncOptions.serverSideApply = true;
    };

    helm.releases.kube-prometheus-stack = {
      chart = charts.prometheus-community.kube-prometheus-stack;

      values = {
        nameOverride = "kube-prometheus";
        fullnameOverride = "kube-prometheus";

        alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec = {
          storageClassName = "longhorn";
          resources.requests.storage = "2Gi";
        };

        grafana = {
          podLabels."networking/component" = "app";
          admin = {
            existingSecret = "grafana";
            userKey = "admin-user";
            passwordKey = "admin-password";
          };
        };

        prometheus = {
          prometheusOperator = {
            livenessProbe = {
              initialDelaySeconds = 30;
              timeoutSeconds = 10;
              periodSeconds = 20;
            };
            readinessProbe = {
              initialDelaySeconds = 30;
              timeoutSeconds = 10;
              periodSeconds = 20;
            };
          };
          prometheusSpec = {
            scrapeTimeout = "30s";
            scrapeInterval = "60s";
            storageSpec.volumeClaimTemplate.spec = {
              storageClassName = "longhorn-nobackup";
              resources.requests.storage = "12Gi";
            };
            resources = {
              requests = {
                cpu = "0.25";
                memory = "1Gi";
              };
              limits = {
                cpu = "1";
                memory = "3Gi";
              };
            };
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./monitoring-secrets.sops.yaml)
    ];

    resources = {
      ingresses.grafana = {
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
              hosts = [ "grafana.cluster.anderwerse.de" ];
              secretName = "grafana-tls";
            }
          ];
          rules = [
            {
              host = "grafana.cluster.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "kube-prometheus-stack-grafana";
                    port.number = 80;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies.grafana = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector = {
            matchLabels = {
              "app.kubernetes.io/name" = "grafana";
            };
          };
          ingress = [
            {
              fromEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "haproxy";
                    "app.kubernetes.io/name" = "kubernetes-ingress";
                  };
                }
                {
                  matchLabels = {
                    "app.kubernetes.io/name" = "prometheus";
                  };
                }
              ];
              fromEntities = [
                "host"
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "3000";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
          egress = [
            {
              toEntities = [
                "kube-apiserver"
              ];
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
                    "app.kubernetes.io/name" = "prometheus";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "9090";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "app" = "longhorn-manager";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "9500";
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
