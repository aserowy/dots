{ charts, ... }:
let
  namespace = "argocd";
in
{
  applications.argocd = {
    inherit namespace;

    helm.releases.argocd = {
      chart = charts.argoproj.argo-cd;

      values = {
        configs = {
          # TODO: introduce module to configure from outside
          cm."resource.exclusions" = ''
            - apiGroups:
              - cilium.io
              kinds:
                - CiliumIdentity
              clusters:
                - "*"
          '';
          params."server.insecure" = "true";
        };
        global.networkPolicy.create = true;
      };
    };

    resources = {
      ingresses.argocd = {
        metadata = {
          inherit namespace;
          annotations = {
            "cert-manager.io/cluster-issuer" = "azure-acme-issuer";
          };
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "argo.cluster.anderwerse.de" ];
              secretName = "argocd-tls";
            }
          ];
          rules = [
            {
              host = "argo.cluster.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "argocd-server";
                    port.number = 80;
                  };
                }
              ];
            }
          ];
        };
      };

      # TODO: remove after traefik migration
      certificates.argo-tls-certificate.spec = {
        secretName = "argo-tls-certificate";
        issuerRef = {
          name = "azure-acme-issuer";
          kind = "ClusterIssuer";
        };
        duration = "2160h";
        renewBefore = "720h";
        dnsNames = [
          "argo.cluster.anderwerse.de"
        ];
      };

      # TODO: remove after traefik migration
      ingressRoutes.argocd-dashboard-route.spec = {
        entryPoints = [
          "websecure"
        ];
        routes = [
          {
            match = "Host(`argo.cluster.anderwerse.de`)";
            kind = "Rule";
            services = [
              {
                name = "argocd-server";
                namespace = "argocd";
                port = 80;
              }
            ];
          }
        ];
        tls.secretName = "argo-tls-certificate";
      };
    };
  };
}
