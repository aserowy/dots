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

    # resources = {
    #   # allow all argocd pods to access kube-apiserver
    #   allow-kube-apiserver-egress.spec = {
    #     endpointSelector.matchLabels."app.kubernetes.io/part-of" = "argocd";
    #     egress = [
    #       {
    #         toEntities = [ "kube-apiserver" ];
    #         toPorts = [
    #           {
    #             ports = [
    #               {
    #                 port = "6443";
    #                 protocol = "TCP";
    #               }
    #             ];
    #           }
    #         ];
    #       }
    #     ];
    #   };
    # };
  };
}
