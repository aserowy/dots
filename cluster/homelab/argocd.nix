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
      ingressRoutes = {
        argocd-dashboard-route.spec = {
          entryPoints = [
            "web"
          ];
          routes = [
            {
              match = "PathPrefix(`/argo`)";
              kind = "Rule";
              services = [
                {
                  name = "argocd-server";
                  port = 443;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
