{ ... }:
{
  applications.dns = {
    namespace = "dns";
    createNamespace = true;

    yamls = [
      (builtins.readFile ./dns-secrets.sops.yaml)

      (builtins.readFile ./adguard-deployment.yaml)
      (builtins.readFile ./adguard-work-pvc.yaml)
    ];

    resources = {
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
