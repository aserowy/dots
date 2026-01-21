{ charts, ... }:
let
  namespace = "nextcloud";
in
{
  applications.nextcloud = {
    inherit namespace;

    createNamespace = true;

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
        cronjob = {
          enabled = true;
          type = "cronjob";
          affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution = [
            {
              weight = 100;
              podAffinityTerm.labelSelector = {
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
        phpClientHttpsFix.enabled = true;

        internalDatabase.enabled = false;
        externalDatabase = {
          enabled = true;
          existingSecret = {
            enabled = true;
            secretName = "database";
          };
        };
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
          initialDelaySeconds = 120;
          failureThreshold = 15;
        };
        readinessProbe = {
          initialDelaySeconds = 120;
          failureThreshold = 15;
        };
      };
    };

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];

    resources = {
      ingressRoutes = {
        nextcloud-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`nextcloud.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "nextcloud";
                  port = 8080;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
      };

      ciliumNetworkPolicies = {
        nextcloud = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector = {
              matchLabels = {
                "app.kubernetes.io/name" = "nextcloud";
              };
            };
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
  };
}
