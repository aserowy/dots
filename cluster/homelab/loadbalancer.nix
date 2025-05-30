{ charts, ... }:
{
  applications.loadbalancer = {
    namespace = "loadbalancer";
    createNamespace = true;

    helm.releases = {
      traefik = {
        chart = charts.traefik.traefik;

        values = {
          additionalArguments = [
            "--log.level=DEBUG"
          ];
        };
      };

      cert-manager = {
        chart = charts.jetstack.cert-manager;

        values = {
          installCRDs = true;
        };
      };
    };

    resources = {
      ciliumLoadBalancerIPPools = {
        traefik-loadbalancer-ippool.spec = {
          # TODO: cidr configurable
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
              match = "Host(`traefik.anderwerse.de`)";
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
