{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases = {
      emqx-operator = {
        chart = charts.emqx.emqx-operator;

        values = {
          singleNamespace = true;
        };
      };
    };

    yamls = [
      # TODO: update with renovate
      ''
        apiVersion: apps.emqx.io/v2beta1
        kind: EMQX
        metadata:
           name: emqx
        spec:
           image: emqx/emqx:5.9.1
      ''
    ];

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
