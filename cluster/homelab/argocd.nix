{ charts, ... }:
{
  applications.argocd = {
    namespace = "argocd";

    helm.releases.argocd = {
      chart = charts.argoproj.argo-cd;

      values = {
        configs.params."server.insecure" = "true";
        global.networkPolicy.create = true;
      };
    };
  };
}
