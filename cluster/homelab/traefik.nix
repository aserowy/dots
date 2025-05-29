{ charts, ... }:
{
  applications.traefik = {
    namespace = "argocd";

    helm.releases.traefik = {
      chart = charts.traefik.traefik;

      values = { };
    };

    resources = { };
  };
}
