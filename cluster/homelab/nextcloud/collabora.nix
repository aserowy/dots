{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.collabora = {
      chart = charts.collabora-online.collabora-online;

      values = {
        # NOTE: without dynamic load hpa is not necessary
        autoscaling.enabled = false;
        replicaCount = 2;

        collabora = {
          aliasgroups = [
            { host = "https://collabora.anderwerse.de:443"; }
            { host = "https://collabora.anderwerse.de:8443"; }
          ];
          extra_params = "--o:storage.wopi.host=nextcloud\\.anderwerse\\.de --o:ssl.enable=false --o:ssl.termination=true";
          existingSecret = {
            enabled = true;
            secretName = "collabora";
          };
          proofKeysSecretRef = "collabora-proof-key";
        };
        resources = {
          requests = {
            cpu = "2000m";
            memory = "2Gi";
          };
          limits = {
            cpu = "4000m";
            memory = "6Gi";
          };
        };
      };
    };

    resources = {
      ingresses = {
        collabora = {
          metadata = {
            inherit namespace;
            annotations = {
              "cert-manager.io/cluster-issuer" = "azure-acme-issuer";
              "haproxy.org/timeout-tunnel" = "3600s";
              "haproxy.org/backend-config-snippet" =
                "balance url_param WOPISrc check_post
                hash-type consistent";
            };
          };
          spec = {
            ingressClassName = "haproxy";
            tls = [
              {
                hosts = [ "collabora.anderwerse.de" ];
                secretName = "collabora-tls";
              }
            ];
            rules = [
              {
                host = "collabora.anderwerse.de";
                http.paths = [
                  {
                    pathType = "ImplementationSpecific";
                    path = "/";
                    backend.service = {
                      name = "collabora-collabora-online";
                      port.number = 9980;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
