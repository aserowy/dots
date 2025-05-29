{ charts, ... }:
{
  applications.traefik = {
    namespace = "loadbalancer";
    createNamespace = true;

    helm.releases.traefik = {
      chart = charts.traefik.traefik;

      values = {
        providers = {
          kubernetesIngress = {
            ingressEndpoint = {
              publishedService.enabled = true;
            };
          };
        };
      };
    };

    resources = { };
  };
}
