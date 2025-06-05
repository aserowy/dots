{ charts, ... }:
{
  applications.monitoring = {
    namespace = "monitoring";
    createNamespace = true;

    helm.releases.kube-prome = {
      chart = charts.prometheus-community.kube-prometheus-stack;
    };
  };
}
