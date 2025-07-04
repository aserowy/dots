{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.zigbee2mqtt = {
      chart = charts.koenkk.zigbee2mqtt;

      values = {
        statefulset = {
          resources = {
            limits = {
              cpu = "200m";
              memory = "600Mi";
              "akri.sh/akri-zigbee-stick" = "1";
            };
            requests = {
              cpu = "200m";
              memory = "600Mi";
              "akri.sh/akri-zigbee-stick" = "1";
            };
          };
          storage.storageClassName = "longhorn";
        };
      };
    };

    resources = {
      ingressRoutes = {
        zigbee2mqtt-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`mqtt.test.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "zigbee2mqtt";
                  port = 8080;
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
