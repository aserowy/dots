{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.nextcloud = {
      chart = charts.nextcloud.nextcloud;

      values = {
        nextcloud = {
          host = "nextcloud.anderwerse.de";
          trustedDomains = [ "nextcloud.anderwerse.de" ];
          existingSecret = {
            enabled = true;
            secretName = "nextcloud";
          };
          defaultConfigs."imaginary.config.php" = true;
          configs = {
            "custom_infrastructure.config.php" =
              "<?php
              $CONFIG = array (
                'trusted_proxies' => ['10.42.0.0/16'],
                'forwarded_for_headers' => ['HTTP_X_FORWARDED', 'HTTP_FORWARDED_FOR'],
              );
              ";
            "custom_maintenance.config.php" =
              "<?php
              $CONFIG = array (
                'maintenance_window_start' => 1,
              );
              ";
            "custom_region.config.php" =
              "<?php
              $CONFIG = array (
                'default_language' => 'en',
                'default_locale' => 'de_DE',
                'default_phone_region' => 'DE',
                'default_timezone' => 'Europe/Berlin',
              );
              ";
          };
        };
        phpClientHttpsFix.enabled = true;

        cronjob = {
          enabled = true;
          type = "cronjob";
          cronjob = {
            securityContext = {
              runAsUser = 33;
              runAsGroup = 33;
              runAsNonRoot = true;
              readOnlyRootFilesystem = true;
            };
            affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution = [
              {
                labelSelector = {
                  matchExpressions = [
                    {
                      key = "app.kubernetes.io/name";
                      operator = "In";
                      values = [ "nextcloud" ];
                    }
                    {
                      key = "app.kubernetes.io/component";
                      operator = "In";
                      values = [ "app" ];
                    }
                  ];
                };
                topologyKey = "kubernetes.io/hostname";
              }
            ];
          };
        };

        persistence = {
          enabled = true;
          storageClass = "longhorn";
          nextcloudData = {
            enabled = true;
            storageClass = "longhorn";
            size = "20Gi";
          };
        };

        imaginary.enabled = true;

        internalDatabase.enabled = false;
        externalDatabase = {
          enabled = true;
          existingSecret = {
            enabled = true;
            secretName = "database";
          };
        };

        # TODO: migrate to cloudnative pg
        postgresql = {
          enabled = true;
          global.postgresql.auth = {
            existingSecret = "database";
            secretKeys = {
              adminPasswordKey = "db-adminpassword";
              userPasswordKey = "db-password";
              replicationPasswordKey = "db-replicationpassword";
            };
          };
          primary.persistence = {
            enabled = true;
            storageClass = "longhorn";
          };
        };

        livenessProbe = {
          initialDelaySeconds = 60;
          # NOTE: high failure threshold to accomodate for possible version migrations
          failureThreshold = 60;
        };
        readinessProbe = {
          initialDelaySeconds = 60;
          # NOTE: high failure threshold to accomodate for possible version migrations
          failureThreshold = 60;
        };
      };
    };

    resources = {
      # NOTE: patch nextcloud deployment to enable labeled ingress in HAProxy
      deployments.nextcloud.spec.template.metadata.labels."haproxy/ingress" = "allow";

      ingresses.nextcloud = {
        metadata = {
          inherit namespace;
          annotations = {
            "cert-manager.io/cluster-issuer" = "azure-acme-issuer";

            "haproxy.org/backend-config-snippet" =
              "http-response set-header Strict-Transport-Security 'max-age=15552000; includeSubDomains; preload;'";
          };
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "nextcloud.anderwerse.de" ];
              secretName = "nextcloud-tls";
            }
          ];
          rules = [
            {
              host = "nextcloud.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "nextcloud";
                    port.number = 8080;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies.nextcloud = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector.matchLabels."app.kubernetes.io/name" = "nextcloud";
          ingress = [
            {
              fromEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "haproxy";
                    "app.kubernetes.io/name" = "kubernetes-ingress";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "80";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
          egress = [
            {
              toEntities = [ "world" ];
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
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "kube-system";
                    "k8s-app" = "kube-dns";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "53";
                      protocol = "UDP";
                    }
                  ];
                }
              ];
            }
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "io.kubernetes.pod.namespace" = "haproxy";
                    "app.kubernetes.io/name" = "kubernetes-ingress";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "8443";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              toEndpoints = [
                {
                  matchLabels = {
                    "app.kubernetes.io/name" = "postgresql";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "5432";
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
