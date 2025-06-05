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
                        name = "PAPERLESS_REDIS";
                        value = "redis://valkey-primary:6379";
                      }
                      {
                        name = "PAPERLESS_DBHOST";
                        value = "postgres";
                      }
                      {
                        name = "PAPERLESS_URL";
                        value = "http://dms.anderwerse.de";
                      }
                      {
                        name = "PAPERLESS_OCR_LANGUAGE";
                        value = "de";
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
    };
  };
}
