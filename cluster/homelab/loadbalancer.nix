{ charts, ... }:
let

in
{
  applications.loadbalancer = {
    namespace = "loadbalancer";
    createNamespace = true;

    helm.releases = {
      traefik = {
        chart = charts.traefik.traefik;

        values = {
          additionalArguments = [
            "--log.level=DEBUG"
          ];
        };
      };

      cert-manager = {
        chart = charts.jetstack.cert-manager;

        values = {
          crds.enabled = true;
        };
      };
    };

    yamls = [
      (builtins.readFile ./loadbalancer-secrets.sops.yaml)
    ];

    resources = {
      issuers = {
        azure-acme-issuer.spec.acme = {
          email = "serowy@hotmail.com";
          server = "https://acme-v02.api.letsencrypt.org/directory";
          privateKeySecretRef.name = "azure-issuer-account-key";
          solvers = [
            {
              dns01 = {
                azureDNS = {
                  clientID = "";
                  clientSecretSecretRef = {
                    name = "azure-acme-environment";
                    key = "AZURE_CLIENT_SECRET";
                  };
                  subscriptionID = "<your-subscription-id>";
                  tenantID = "<your-tenant-id>";
                  resourceGroupName = "<your-resource-group>";
                  hostedZoneName = "<your-hosted-zone>";
                };
              };
            }
          ];
        };
      };
      ciliumLoadBalancerIPPools = {
        traefik-loadbalancer-ippool.spec = {
          # TODO: cidr configurable
          blocks = [ { cidr = "192.168.178.53/32"; } ];
        };
      };
      ingressRoutes = {
        traefik-dashboard-route.spec = {
          entryPoints = [
            "web"
          ];
          routes = [
            {
              match = "Host(`traefik.anderwerse.de`)";
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
