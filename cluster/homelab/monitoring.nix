{ charts, ... }:
{
  applications.monitoring = {
    namespace = "monitoring";
    createNamespace = true;

    helm.releases.kube-prometheus = {
      chart = charts.prometheus-community.kube-prometheus-stack;
    };
  };
}
