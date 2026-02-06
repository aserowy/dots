{ charts, lib, ... }:
let
  namespace = "monitoring";

  serverEndpoints = [
    "192.168.178.201"
    "192.168.178.203"
    "192.168.178.205"
  ];
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

    # TODO: taint prometheus to use 16gb nodes only
    # TODO: netpol (flavor cilium) with helm chart
    helm.releases.kube-prometheus-stack = {
      chart = charts.prometheus-community.kube-prometheus-stack;

      values = {
        nameOverride = "kube-prometheus";
        fullnameOverride = "kube-prometheus";

        alertmanager = {
          config = {
            global = {
              smtp_auth_username = "cluster-monitor";
              smtp_auth_password_file = "/etc/alertmanager/secrets/alertmanager-acs-secret/password";
              smtp_from = "DoNotReply@anderwerse.de";
              smtp_smarthost = "smtp.azurecomm.net:587";
            };

            route = {
              group_by = [ "namespace" ];
              group_wait = "30s";
              group_interval = "5m";
              repeat_interval = "12h";
              receiver = "default-receiver";
              routes = [ ];
            };

            receivers = [
              {
                name = "default-receiver";
                email_configs = [
                  {
                    to = "serowy@hotmail.com";
                    headers.Subject = "[{{ .Status | toUpper }}] {{ .GroupLabels.namespace }}";
                  }
                ];
              }
            ];
          };

          alertmanagerSpec = {
            podMetadata.labels."haproxy/egress" = "allow";

            replicas = 2;
            secrets = ["alertmanager-acs-secret"];
            storage.volumeClaimTemplate.spec = {
              storageClassName = "longhorn";
              resources.requests.storage = "2Gi";
            };
          };
        };

        grafana = {
          podLabels."haproxy/egress" = "allow";
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
            # TODO: increase to 2 after tainting
            replicas = 1;
            podMetadata.labels."haproxy/egress" = "allow";
            retention = "7d";
            scrapeTimeout = "30s";
            scrapeInterval = "60s";
            storageSpec.volumeClaimTemplate.spec = {
              storageClassName = "longhorn-nobackup";
              resources.requests.storage = "12Gi";
            };
            resources = {
              requests = {
                cpu = "500m";
                memory = "2.5Gi";
              };
            };
          };
        };

        # NOTE: kube proxy is disabled in favor of cilium
        kubeProxy.enabled = false;

        kubeControllerManager = {
          enabled = true;

          # NOTE: k3s specific configuration to enable metrics for controller manager
          endpoints = serverEndpoints;
          service = {
            enabled = true;
            port = 10257;
            targetPort = 10257;
          };
          serviceMonitor = {
            enabled = true;
            https = true;
          };
        };

        kubeScheduler = {
          enabled = true;

          # NOTE: k3s specific configuration to enable metrics for scheduler
          endpoints = serverEndpoints;
          service = {
            enabled = true;
            port = 10259;
            targetPort = 10259;
          };
          serviceMonitor = {
            enabled = true;
            https = true;
          };
        };

        kubeEtcd = {
          enabled = true;

          # NOTE: k3s specific configuration to enable metrics on etcd nodes
          endpoints = serverEndpoints;
          service = {
            enabled = true;
            port = 2381;
            targetPort = 2381;
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./monitoring-secrets.sops.yaml)
    ];

    resources = {
      statefulSets.prometheus-kube-prometheus-prometheus.spec.template = {
        spec.containers.prometheus.resources.limits = lib.mkForce null;
      };

      ingresses = {
        alertmanager = {
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
                hosts = [ "alertmanager.cluster.anderwerse.de" ];
                secretName = "alertmanager-tls";
              }
            ];
            rules = [
              {
                host = "alertmanager.cluster.anderwerse.de";
                http.paths = [
                  {
                    pathType = "Prefix";
                    path = "/";
                    backend.service = {
                      name = "kube-prometheus-alertmanager";
                      port.number = 9093;
                    };
                  }
                ];
              }
            ];
          };
        };
        grafana = {
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
        prometheus = {
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
                hosts = [ "prometheus.cluster.anderwerse.de" ];
                secretName = "prometheus-tls";
              }
            ];
            rules = [
              {
                host = "prometheus.cluster.anderwerse.de";
                http.paths = [
                  {
                    pathType = "Prefix";
                    path = "/";
                    backend.service = {
                      name = "kube-prometheus-prometheus";
                      port.number = 9090;
                    };
                  }
                ];
              }
            ];
          };
        };
      };

      # TODO: netpol alertmanager and prometheus
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
            # NOTE: combining fromEndpoints and fromEntities is not supported
            {
              fromEntities = [ "host" ];
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
