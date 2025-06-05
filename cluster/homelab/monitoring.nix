{ charts, ... }:
{
  applications.monitoring = {
    namespace = "monitoring";
    createNamespace = true;

    helm.releases.kube-prom = {
      chart = charts.prometheus-community.kube-prometheus-stack;
    };
  };
}
