{ charts, lib, ... }:
let
  namespace = "dms";
  paperless-media-pvc = "paperless-media-pvc";
  paperless-data-pvc = "paperless-data-pvc";
in
{
  applications.dms = {
    inherit namespace;
    createNamespace = true;

    helm.releases = {
      postgresql = {
        chart = charts.bitnami.postgresql;

        values = {
          auth = {
            database = "paperless";
            username = "paperless";
            existingSecret = "postgresql";
          };
        };
      };

      valkey = {
        # TODO: renovate update template for this and remove nix helm?
        chart = lib.helm.downloadHelmChart {
          repo = "https://charts.bitnami.com/bitnami/";
          chart = "valkey";
          version = "3.0.9";
          chartHash = "sha256-zSLEopYHW05p7OxZlcusR9SQcmtGnKji6CcQPl9s0xA=";
        };

        values = {
          auth = {
            existingSecret = "valkey";
            existingSecretPasswordKey = "password";
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./dms-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${paperless-media-pvc}
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
      ''
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${paperless-data-pvc}
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
      ''
    ];

    resources = {
      deployments = {
        adguard = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            inherit namespace;
            name = "paperless";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "paperless";
              };
            };
            strategy = {
              type = "RollingUpdate";
            };
            template = {
              metadata = {
                labels = {
                  app = "paperless";
                };
              };
              spec = {
                securityContext = {
                  seccompProfile = {
                    type = "RuntimeDefault";
                  };
                };
                containers = [
                  {
                    name = "paperless";
                    image = "docker.io/paperlessngx/paperless-ngx:2.16";
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    env = [
                      {
                        name = "PAPERLESS_DBHOST";
                        value = "postgresql.dms.svc.cluster.local";
                      }
                      {
                        name = "PAPERLESS_URL";
                        value = "http://dms.anderwerse.de";
                      }
                      {
                        name = "PAPERLESS_OCR_LANGUAGE";
                        value = "deu";
                      }
                      {
                        name = "PAPERLESS_ADMIN_USER";
                        valueFrom.secretKeyRef = {
                          name = "paperless";
                          key = "admin";
                        };
                      }
                      {
                        name = "PAPERLESS_ADMIN_PASSWORD";
                        valueFrom.secretKeyRef = {
                          name = "paperless";
                          key = "password";
                        };
                      }
                      {
                        name = "PAPERLESS_SECRET_KEY";
                        valueFrom.secretKeyRef = {
                          name = "paperless";
                          key = "secretkey";
                        };
                      }
                      {
                        name = "PAPERLESS_REDIS";
                        valueFrom.secretKeyRef = {
                          name = "paperless";
                          key = "redis";
                        };
                      }
                      {
                        name = "PAPERLESS_DBPASS";
                        valueFrom.secretKeyRef = {
                          name = "postgresql";
                          key = "password";
                        };
                      }
                    ];
                    ports = [
                      {
                        name = "http";
                        containerPort = 8000;
                        protocol = "TCP";
                      }
                    ];
                    resources = {
                      requests = {
                        cpu = "100m";
                        memory = "128Mi";
                      };
                      limits = {
                        cpu = "1000m";
                        memory = "1Gi";
                      };
                    };
                    volumeMounts = [
                      {
                        name = "run";
                        mountPath = "/run";
                      }
                      {
                        name = "tmp";
                        mountPath = "/tmp";
                      }
                      {
                        name = "data";
                        mountPath = "/usr/src/paperless/data";
                      }
                      {
                        name = "media";
                        mountPath = "/usr/src/paperless/media";
                      }
                      {
                        name = "export";
                        mountPath = "/usr/src/paperless/export";
                      }
                      {
                        name = "consume";
                        mountPath = "/usr/src/paperless/consume";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "run";
                    emptyDir.sizeLimit = "500Mi";
                  }
                  {
                    name = "tmp";
                    emptyDir.sizeLimit = "500Mi";
                  }
                  {
                    name = "export";
                    emptyDir = { };
                  }
                  {
                    name = "consume";
                    emptyDir = { };
                  }
                  {
                    name = "data";
                    persistentVolumeClaim = {
                      claimName = paperless-media-pvc;
                    };
                  }
                  {
                    name = "media";
                    persistentVolumeClaim = {
                      claimName = paperless-data-pvc;
                    };
                  }
                ];
              };
            };
          };
        };
      };
      services = {
        paperless = {
          metadata = {
            inherit namespace;
            name = "paperless";
          };
          spec = {
            selector = {
              app = "paperless";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 8000;
              }
            ];
          };
        };
      };
      ingressRoutes = {
        paperless-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`dms.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "paperless";
                  port = 8000;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
      };
    };
  };
}
