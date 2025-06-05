{ charts, ... }:
{
  applications.monitoring = {
    namespace = "monitoring";
    createNamespace = true;

    syncPolicy.syncOptions = {
      replace = true;
      serverSideApply = true;
    };

    helm.releases.kube-prome = {
      chart = charts.prometheus-community.kube-prometheus-stack;
    };
  };
}
