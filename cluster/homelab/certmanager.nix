{ charts, ... }:
{
  applications.certmanager = {
    namespace = "loadbalancer";
    createNamespace = true;

    helm.releases.certmanager = {
      chart = charts.jetstack.cert-manager;

      values = {
      };
    };

    resources = {
    };
  };
}
