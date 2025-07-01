{ charts, ... }:
{
  applications.certificates = {
    namespace = "certificates";
    createNamespace = true;

    helm.releases = {
      cert-manager = {
        chart = charts.jetstack.cert-manager;

        values = {
          crds.enabled = true;
        };
      };
    };
  };
}
