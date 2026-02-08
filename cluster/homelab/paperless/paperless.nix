{
  application,
  namespace,
  ...
}:
let
  paperless-consume-pvc = "paperless-consume-pvc";
  paperless-data-pvc = "paperless-data-pvc";
  paperless-media-pvc = "paperless-media-pvc";
in
{
  applications."${application}" = {
    resources = {
      clusters.paperless-pg17 = {
        spec = {
          instances = 2;
          imageCatalogRef = {
            apiGroup = "postgresql.cnpg.io";
            kind = "ClusterImageCatalog";
            name = "trixie";
            major = 17;
          };
          storage.size = "2Gi";

          bootstrap.initdb = {
            owner = "paperless";
            database = "paperless";
            secret.name = "paperless-pg";
          };

          resources.requests = {
            cpu = "150m";
            memory = "300Mi";
          };

          managed.services.disabledDefaultServices = [
            "ro"
            "r"
          ];
        };
      };

      statefulSets.paperless = {
        apiVersion = "apps/v1";
        metadata = {
          inherit namespace;
          name = "paperless";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "paperless";
          template = {
            metadata.labels = {
              "app.kubernetes.io/name" = "paperless";
              "app.kubernetes.io/component" = "app";
            };
            spec = {
              securityContext = {
                seccompProfile = {
                  type = "RuntimeDefault";
                };
              };
              initContainers = [
                {
                  name = "await-db-init";
                  image = "busybox:1.37"; # docker/busybox@semver-coerced
                  command = [
                    "sh"
                    "-c"
                    "until nc -z paperless-pg17-rw 5432; do echo 'waiting for postgresql.'; sleep 5; done"
                  ];
                }
              ];
              containers = [
                {
                  name = "paperless";
                  image = "docker.io/paperlessngx/paperless-ngx:2.20.6"; # docker/paperlessngx/paperless-ngx@semver-coerced
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
                      value = "paperless-pg17-rw.paperless.svc.cluster.local";
                    }
                    {
                      name = "PAPERLESS_URL";
                      value = "https://paperless.anderwerse.de";
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
                        name = "paperless";
                        key = "postgresql-password";
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
                  resources.requests = {
                    cpu = "350m";
                    memory = "1600Mi";
                  };
                  startupProbe = {
                    tcpSocket.port = 8000;
                    initialDelaySeconds = 45;
                    periodSeconds = 10;
                    failureThreshold = 5;
                  };
                  livenessProbe.tcpSocket.port = 8000;
                  readinessProbe.tcpSocket.port = 8000;
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
                  persistentVolumeClaim.claimName = paperless-consume-pvc;
                }
                {
                  name = "data";
                  persistentVolumeClaim.claimName = paperless-data-pvc;
                }
                {
                  name = "media";
                  persistentVolumeClaim.claimName = paperless-media-pvc;
                }
              ];
            };
          };
        };
      };

      cronJobs."paperless-nextcloud-importer" = {
        metadata = {
          inherit namespace;
          name = "paperless-nextcloud-importer";
        };
        spec = {
          schedule = "*/5 * * * *";
          jobTemplate.spec.template = {
            metadata.labels = {
              "app.kubernetes.io/name" = "paperless-nextcloud-importer";
              "haproxy/ingress" = "allow";
            };
            spec = {
              restartPolicy = "Never";
              affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution = [
                {
                  labelSelector.matchLabels."app.kubernetes.io/name" = "paperless";
                  topologyKey = "kubernetes.io/hostname";
                }
              ];
              containers = [
                {
                  name = "rclone-move";
                  image = "rclone/rclone:1.73"; # docker/rclone/rclone@semver-coerced
                  imagePullPolicy = "IfNotPresent";
                  args = [
                    "move"
                    "nextcloud:/Paperless"
                    "/consume"
                    "--transfers=1"
                    "--checkers=1"
                    "--no-traverse"
                    "--retries=3"
                    "--log-level=DEBUG"
                  ];
                  env = [
                    {
                      name = "RCLONE_CONFIG_NEXTCLOUD_TYPE";
                      value = "webdav";
                    }
                    {
                      name = "RCLONE_CONFIG_NEXTCLOUD_URL";
                      valueFrom = {
                        secretKeyRef = {
                          name = "nextcloud";
                          key = "url";
                        };
                      };
                    }
                    {
                      name = "RCLONE_CONFIG_NEXTCLOUD_VENDOR";
                      value = "nextcloud";
                    }
                    {
                      name = "RCLONE_CONFIG_NEXTCLOUD_USER";
                      valueFrom = {
                        secretKeyRef = {
                          name = "nextcloud";
                          key = "user";
                        };
                      };
                    }
                    {
                      name = "RCLONE_CONFIG_NEXTCLOUD_PASS";
                      valueFrom = {
                        secretKeyRef = {
                          name = "nextcloud";
                          key = "password";
                        };
                      };
                    }
                  ];
                  volumeMounts = [
                    {
                      name = "consume";
                      mountPath = "/consume";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "consume";
                  persistentVolumeClaim.claimName = paperless-consume-pvc;
                }
              ];
            };
          };
        };
      };

      services.paperless = {
        metadata = {
          inherit namespace;
          name = "paperless";
        };
        spec = {
          selector."app.kubernetes.io/name" = "paperless";
          ports = [
            {
              name = "http";
              protocol = "TCP";
              port = 8000;
            }
          ];
        };
      };

      ingresses.paperless = {
        metadata = {
          inherit namespace;
          annotations = {
            "cert-manager.io/cluster-issuer" = "azure-acme-issuer";
          };
        };
        spec = {
          ingressClassName = "haproxy";
          tls = [
            {
              hosts = [ "paperless.anderwerse.de" ];
              secretName = "paperless-tls";
            }
          ];
          rules = [
            {
              host = "paperless.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "paperless";
                    port.number = 8000;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies = {
        paperless = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels."app.kubernetes.io/name" = "paperless";
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
                        port = "8000";
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
                        port = "993";
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
                      "app.kubernetes.io/name" = "gotenberg";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "3000";
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
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "tika";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "9998";
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
                      "app.kubernetes.io/name" = "valkey";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "6379";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
          };
        };

        paperless-nextcloud-importer = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels."app.kubernetes.io/name" = "paperless-nextcloud-importer";
            egress = [
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
            ];
          };
        };

        paperless-pg = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "postgresql";
            };
            ingress = [
              # NOTE: combining fromEndpoints and fromEntities is not supported
              {
                fromEntities = [ "host" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "io.kubernetes.pod.namespace" = "cnpg-system";
                      "app.kubernetes.io/name" = "cloudnative-pg";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEndpoints = [
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
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/name" = "paperless";
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
                      {
                        port = "8000";
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

    yamls = [
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${paperless-consume-pvc}
        spec:
          storageClassName: "longhorn-nobackup"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 200Mi
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
    ];
  };
}
