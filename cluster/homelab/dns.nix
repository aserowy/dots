{ charts, ... }:
{
  applications.dns = {
    namespace = "dns";
    createNamespace = true;

    helm.releases.pihole = {
      chart = charts.mojo2600.pihole;

      values = {
        persistentVolumeClaim = {
          enabled = true;
        };
      };
    };

    resources = {
      ingressRoutes = {
        cilium-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`dns.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  name = "pihole-web";
                  namespace = "dns";
                  port = 80;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
      };
    };
  };
}
