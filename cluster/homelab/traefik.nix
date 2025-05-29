{ charts, ... }:
{
  nixidy.resourceImports = [
    ../crd/traefik.nix
  ];

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
      ingressRoutes = {
        traefik-dashboard-route.spec = {
          entryPoints = [
            "web"
          ];
          routes = [
            {
              match = "Host(`*`)";
              kind = "Rule";
              services = [
                {
                  name = "api@internal";
                  kind = "TraefikService";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
