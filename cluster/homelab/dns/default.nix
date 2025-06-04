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
      services = {
        adguard-service = {
          metadata = {
            inherit namespace;
            name = "adguard-service";
          };
          spec = {
            selector = {
              app = "adguard";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 3000;
              }
              {
                name = "dns-tcp";
                protocol = "TCP";
                port = 53;
              }
              {
                name = "dns-udp";
                protocol = "UDP";
                port = 53;
              }
              {
                name = "dhcp";
                protocol = "UDP";
                port = 67;
              }
            ];
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
                  inherit namespace;
                  name = "adguard-service";
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
