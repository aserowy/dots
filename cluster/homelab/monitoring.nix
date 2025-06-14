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
  };
}
