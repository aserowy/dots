{
  application,
  namespace,
  charts,
  ...
}:
let
  paperless-media-pvc = "paperless-media-pvc";
  paperless-data-pvc = "paperless-data-pvc";
in
{
  applications."${application}" = {
    helm.releases.postgresql = {
      chart = charts.bitnami.postgresql;
      values = {
        auth = {
          database = "paperless";
          username = "paperless";
          existingSecret = "postgresql";
        };
      };
    };

    yamls = [
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${paperless-media-pvc}
        spec:
          storageClassName: "longhorn"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 5Gi
      ''
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${paperless-data-pvc}
        spec:
          storageClassName: "longhorn"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 8Gi
      ''
    ];

    resources = {
      statefulSets = {
        paperless = {
          apiVersion = "apps/v1";
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
                    image = "docker.io/paperlessngx/paperless-ngx:2.18.4"; # docker/paperlessngx/paperless-ngx@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    env = [
                      {
                        # NOTE: see `granian fails to start with "is not a valid port number"`
                        # in https://docs.paperless-ngx.com/troubleshooting/
                        name = "PAPERLESS_PORT";
                        value = "8000";
                      }
                      {
                        name = "PAPERLESS_DBHOST";
                        value = "postgresql.paperless.svc.cluster.local";
                      }
                      {
                        name = "PAPERLESS_URL";
                        value = "https://dms.anderwerse.de";
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
                      {
                        name = "PAPERLESS_OUTLOOK_OAUTH_CLIENT_ID";
                        valueFrom.secretKeyRef = {
                          name = "paperless";
                          key = "outlook-client-id";
                        };
                      }
                      {
                        name = "PAPERLESS_OUTLOOK_OAUTH_CLIENT_SECRET";
                        valueFrom.secretKeyRef = {
                          name = "paperless";
                          key = "outlook-client-secret";
                        };
                      }
                      {
                        name = "PAPERLESS_TIKA_ENABLED";
                        value = "1";
                      }
                      {
                        name = "PAPERLESS_TIKA_GOTENBERG_ENDPOINT";
                        value = "http://gotenberg.paperless.svc.cluster.local:3000";
                      }
                      {
                        name = "PAPERLESS_TIKA_ENDPOINT";
                        value = "http://tika.paperless.svc.cluster.local:9998";
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
                        memory = "2Gi";
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
                      claimName = paperless-data-pvc;
                    };
                  }
                  {
                    name = "media";
                    persistentVolumeClaim = {
                      claimName = paperless-media-pvc;
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
