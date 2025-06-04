{ ... }:
let
  namespace = "dns";
in
{
  applications.dns = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./dns-secrets.sops.yaml)

      (builtins.readFile ./adguard-deployment.yaml)
      (builtins.readFile ./adguard-work-pvc.yaml)
    ];

    resources = {
      configMaps = {
        adguard-cm = {
          metadata = {
            inherit namespace;
            name = "adguard-cm";
          };
          data = {
            "adguardhome.yaml" = (builtins.readFile ./adguard-config.yaml);
          };
        };
      };

      ingressRoutes = {
        adguard-dashboard-route.spec = {
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
