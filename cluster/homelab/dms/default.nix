{ ... }:
let
  namespace = "dms";
in
{
  applications.dms = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./dms-secrets.sops.yaml)

      (builtins.readFile ./paperless-deployment.yaml)
      (builtins.readFile ./paperless-pvc.yaml)
    ];

    resources = {
      configMaps = {
        paperless-cm = {
          metadata = {
            inherit namespace;
            name = "paperless-cm";
          };
          data = {
            "paperlesshome.yaml" = (builtins.readFile ./paperless-config.yaml);
          };
        };
      };
      services = {
        paperless-dashboard = {
          metadata = {
            inherit namespace;
            name = "paperless-dashboard";
          };
          spec = {
            selector = {
              app = "paperless";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 3000;
              }
            ];
          };
        };
      };
      ingressRoutes = {
        paperless-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`dms.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "paperless-dashboard";
                  port = 3000;
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
