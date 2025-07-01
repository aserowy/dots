{ application, charts, ... }:
{
  applications."${application}" = {
    helm.releases = {
      cert-manager = {
        chart = charts.jetstack.cert-manager;

        values = {
          crds.enabled = false;
        };
      };
    };

    resources = {
    };
  };
}
