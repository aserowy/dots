{ charts, ... }:
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
          service = {
            annotations = {
              "lbipam.cilium.io/sharing-cross-namespace" = "*";
              "lbipam.cilium.io/sharing-key" = "default-ippool";
            };
            labels = {
              "homelab/loadbalancer" = "entrypoint";
            };
          };
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
                  clientID = "e48f89f8-a7ac-45c6-8d9c-10edbf3365cb";
                  clientSecretSecretRef = {
                    name = "azure-acme-environment";
                    key = "AZURE_CLIENT_SECRET";
                  };
                  subscriptionID = "b0f74bb3-5530-4ad4-a307-dc6a96b371c0";
                  tenantID = "fe7eb9da-a96c-4ffd-8fe0-fd1ec4f77439";
                  resourceGroupName = "rg_homelab";
                  hostedZoneName = "anderwerse.de";
                };
              };
            }
          ];
        };
      };
      certificates = {
        anderwersede-tls-certificate.spec = {
          secretName = "anderwersede-tls-certificate";
          issuerRef = {
            name = "azure-acme-issuer";
            kind = "Issuer";
          };
          duration = "2160h";
          renewBefore = "720h";
          dnsNames = [
            "*.anderwerse.de"
          ];
        };
      };
      ingressRoutes = {
        traefik-dashboard-route.spec = {
          entryPoints = [
            "websecure"
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
          tls.secretName = "anderwersede-tls-certificate";
        };
      };
    };
  };
}
