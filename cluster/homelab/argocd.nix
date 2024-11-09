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
    ciliumNetworkPolicies = {
      allow-world-egress.spec = {
        endpointSelector.matchLabels."app.kubernetes.io/name" = "argocd-repo-server";
        egress = [
          {
            toEndpoints = [
              {
                matchLabels = {
                  "k8s:io.kubernetes.pod.namespace" = "kube-system";
                  "k8s:k8s-app" = "kube-dns";
                };
              }
            ];
            toPorts = [
              {
                ports = [
                  {
                    port = "53";
                    protocol = "ANY";
                  }
                ];
                rules.dns = [
                  { matchPattern = "*"; }
                ];
              }
            ];
          }
          {
            toFQDNs = [
              { matchName = "github.com"; }
            ];
            toPorts = [
              {
                ports = [
                  {
                    port = "443";
                    protocol = "TCP";
                  }
                ];
              }
            ];
          }
        ];
      };

      allow-kube-apiserver-egress.spec = {
        endpointSelector.matchLabels."app.kubernetes.io/part-of" = "argocd";
        egress = [
          {
            toEntities = [ "kube-apiserver" ];
            toPorts = [
              {
                ports = [
                  {
                    port = "6443";
                    protocol = "TCP";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
    };
  };
}
