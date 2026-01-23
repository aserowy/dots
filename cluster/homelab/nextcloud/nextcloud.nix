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
      middlewares.nextcloud-hsts-middleware = {
        metadata = {
          inherit namespace;
          name = "nextcloud-hsts-middleware";
        };
        spec.headers = {
          stsSeconds = 15552000;
          stsIncludeSubdomains = true;
          stsPreload = true;
        };
      };

      ingressRoutes.nextcloud-route.spec = {
        entryPoints = [
          "websecure"
        ];
        routes = [
          {
            kind = "Rule";
            match = "Host(`nextcloud.anderwerse.de`)";
            middlewares = [
              {
                inherit namespace;
                name = "nextcloud-hsts-middleware";
              }
            ];
            services = [
              {
                inherit namespace;
                name = "nextcloud";
                port = 8080;
              }
            ];
          }
        ];
        tls.secretName = "nextcloud-tls-certificate";
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
                    "io.kubernetes.pod.namespace" = "loadbalancer";
                    "app.kubernetes.io/role" = "entrypoint";
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
