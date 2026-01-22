{ charts, ... }:
{
  applications.argocd = {
    namespace = "argocd";

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
