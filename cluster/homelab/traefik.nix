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
      # ciliumNetworkPolicies = {
      #   allow-traefik-to-server-egress.spec = {
      #     endpointSelector.matchLabels."app.kubernetes.io/name" = "traefik";
      #     egress = [
      #       {
      #         toEntities = [ "all" ];
      #       }
      #     ];
      #   };
      # };
      ingressRoutes = {
        traefik-dashboard-route.spec = {
          entryPoints = [
            "web"
          ];
          routes = [
            {
              match = "PathPrefix(`/traefik`)";
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
