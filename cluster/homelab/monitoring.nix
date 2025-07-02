{ charts, ... }:
{
  applications.monitoring = {
    namespace = "monitoring";
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

        grafana.admin = {
          existingSecret = "grafana";
          userKey = "admin-user";
          passwordKey = "admin-password";
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
              storageClassName = "longhorn";
              resources.requests.storage = "5Gi";
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

    resources.ingressRoutes.grafana-route.spec = {
      entryPoints = [
        "websecure"
      ];
      routes = [
        {
          match = "Host(`cluster.anderwerse.de`)";
          kind = "Rule";
          services = [
            {
              name = "kube-prometheus-stack-grafana";
              namespace = "monitoring";
              port = 80;
            }
          ];
        }
      ];
      tls.secretName = "anderwersede-tls-certificate";
    };

    yamls = [
      (builtins.readFile ./monitoring-secrets.sops.yaml)
    ];
  };
}
