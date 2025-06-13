{ charts, ... }:
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
        chart = charts.bitnami.valkey;

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
        gotenberg = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            inherit namespace;
            name = "gotenberg";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "gotenberg";
              };
            };
            strategy = {
              type = "RollingUpdate";
            };
            template = {
              metadata = {
                labels = {
                  app = "gotenberg";
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
                    name = "gotenberg";
                    image = "docker.io/gotenberg/gotenberg:8.21"; # docker/gotenberg/gotenberg@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    env = [
                      {
                        name = "CHROMIUM_DISABLE_JAVASCRIPT";
                        value = "true";
                      }
                      {
                        name = "CHROMIUM_ALLOW_LIST";
                        value = "file:///tmp/.*";
                      }
                    ];
                    ports = [
                      {
                        name = "http";
                        containerPort = 3000;
                        protocol = "TCP";
                      }
                    ];
                    resources = {
                      requests = {
                        cpu = "200m";
                        memory = "512Mi";
                      };
                      limits = {
                        cpu = "1000m";
                        memory = "512Mi";
                      };
                    };
                    volumeMounts = [
                      {
                        name = "home";
                        mountPath = "/home/gotenberg";
                      }
                      {
                        name = "tmp";
                        mountPath = "/tmp";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "home";
                    emptyDir.sizeLimit = "500Mi";
                  }
                  {
                    name = "tmp";
                    emptyDir.sizeLimit = "500Mi";
                  }
                ];
              };
            };
          };
        };
        tika = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            inherit namespace;
            name = "tika";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "tika";
              };
            };
            strategy = {
              type = "RollingUpdate";
            };
            template = {
              metadata = {
                labels = {
                  app = "tika";
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
                    name = "tika";
                    image = "docker.io/apache/tika:3.2.0.0"; # docker/apache/tika@semver-coerced
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    ports = [
                      {
                        name = "http";
                        containerPort = 9998;
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
                        name = "tmp";
                        mountPath = "/tmp";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "tmp";
                    emptyDir.sizeLimit = "1Gi";
                  }
                ];
              };
            };
          };
        };
        paperless = {
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
                    image = "docker.io/paperlessngx/paperless-ngx:2.16"; # docker/paperlessngx/paperless-ngx@semver-coerced
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
                        value = "postgresql.dms.svc.cluster.local";
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
                        value = "http://gotenberg.dms.svc.cluster.local:3000";
                      }
                      {
                        name = "PAPERLESS_TIKA_ENDPOINT";
                        value = "http://tika.dms.svc.cluster.local:9998";
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
        gotenberg = {
          metadata = {
            inherit namespace;
            name = "gotenberg";
          };
          spec = {
            selector = {
              app = "gotenberg";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 3000;
              }
            ];
          };
        };
        tika = {
          metadata = {
            inherit namespace;
            name = "tika";
          };
          spec = {
            selector = {
              app = "tika";
            };
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 9998;
              }
            ];
          };
        };
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
