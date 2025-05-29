{ charts, ... }:
{
  applications.traefik = {
    namespace = "loadbalancer";
    createNamespace = true;

    helm.releases.traefik = {
      chart = charts.traefik.traefik;

      values = {
        additionalArguments = [
          "--log.level=DEBUG"
        ];
      };
    };

    resources = { };
  };
}
