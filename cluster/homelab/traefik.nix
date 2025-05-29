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
      ciliumLoadBalancerIPPools = {
        traefik-loadbalancer-ippool.spec = {
          blocks = [ { cidr = "192.168.178.53/32"; } ];
        };
      };
      ingressRoutes = {
        traefik-dashboard-route.spec = {
          entryPoints = [
            "web"
          ];
          routes = [
            {
              match = "Host(`traefik.smart.home`)";
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
