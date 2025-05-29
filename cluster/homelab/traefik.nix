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

    resources = {
      IngressRoute.spec = {
        entryPoints = "web";
        routes = {
          match = "Host(`*`)";
          kind = "Rule";
          services = [
            {
              name = "api@internal";
              kind = "traefik";
            }
          ];
        };
      };
    };
  };
}
