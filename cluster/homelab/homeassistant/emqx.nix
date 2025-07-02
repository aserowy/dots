{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.emqx = {
      chart = charts.emqx.emqx;

      values = {
        persistence = {
          enabled = true;
          storageClass = "longhorn";
          size = "1Gi";
        };
      };
    };

    resources = {
      ingressRoutes = {
        emqx-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`mqtt.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "emqx";
                  port = 18083;
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
