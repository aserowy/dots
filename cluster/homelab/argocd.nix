{ charts, ... }:
let
  namespace = "argocd";
in
{
  applications.argocd = {
    inherit namespace;

    syncPolicy.syncOptions = {
      # clientSideApplyMigration = false;
      serverSideApply = true;
    };

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
        server.podLabels."haproxy/egress" = "allow";
      };
    };

    resources.ingresses.argocd = {
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
  };
}
