{ charts, ... }:
{
  applications.monitoring = {
    namespace = "monitoring";
    createNamespace = true;

    syncPolicy.syncOptions = {
      replace = true;
      serverSideApply = true;
    };

    helm.releases.kube-prometheus-stack = {
      chart = charts.prometheus-community.kube-prometheus-stack;

      values = {
        nameOverride = "kube-prometheus";
        fullnameOverride = "kube-prometheus";
        prometheus = {
          prometheusSpec = {
            resources = {
              requests = {
                cpu = "250m";
                memory = "1Gi";
              };
              limits = {
                cpu = "1000m";
                memory = "2Gi";
              };
            };
          };
        };
      };
    };
  };
}
