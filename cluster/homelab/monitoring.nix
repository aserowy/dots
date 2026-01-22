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
      certificates.monitoring-tls-certificate.spec = {
        secretName = "monitoring-tls-certificate";
        issuerRef = {
          name = "azure-acme-issuer";
          kind = "ClusterIssuer";
        };
        duration = "2160h";
        renewBefore = "720h";
        dnsNames = [
          "grafana.cluster.anderwerse.de"
        ];
      };

      ingressRoutes.grafana-route.spec = {
        entryPoints = [
          "websecure"
        ];
        routes = [
          {
            match = "Host(`grafana.cluster.anderwerse.de`)";
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
        tls.secretName = "monitoring-tls-certificate";
      };
    };
  };
}
