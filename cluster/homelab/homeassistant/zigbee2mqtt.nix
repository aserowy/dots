{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases = {
      # emqx-operator = {
      #   chart = charts.emqx.emqx-operator;
      #
      #   values = {
      #     singleNamespace = true;
      #   };
      # };
    };

    resources = {
      ingressRoutes = {
        # emqx-dashboard-route.spec = {
        #   entryPoints = [
        #     "websecure"
        #   ];
        #   routes = [
        #     {
        #       match = "Host(`mqtt.anderwerse.de`)";
        #       kind = "Rule";
        #       services = [
        #         {
        #           inherit namespace;
        #           name = "emqx";
        #           port = 18083;
        #         }
        #       ];
        #     }
        #   ];
        #   tls.secretName = "anderwersede-tls-certificate";
        # };
      };
    };
  };
}
