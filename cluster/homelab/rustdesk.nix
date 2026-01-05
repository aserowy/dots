{ ... }:
let
  application = "rustdesk";
  namespace = application;

  rustdesk-relay-pvc = "rustdesk-relay-pvc";
  rustdesk-server-pvc = "rustdesk-server-pvc";
in
{
  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${rustdesk-server-pvc}
        spec:
          storageClassName: "longhorn-nobackup"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100Mi
      ''
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: ${rustdesk-relay-pvc}
        spec:
          storageClassName: "longhorn-nobackup"
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100Mi
      ''
    ];

    resources = {
      statefulSets.rustdesk = {
        apiVersion = "apps/v1";
        metadata = {
          inherit namespace;
          name = "rustdesk";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "rustdesk";
          template = {
            metadata.labels = {
              "app.kubernetes.io/name" = "rustdesk";
              "app.kubernetes.io/component" = "frontend";
            };
            spec = {
              securityContext = {
                fsGroup = 1000;
                runAsGroup = 1000;
                runAsUser = 1000;
                runAsNonRoot = true;
              };
              containers = [
                {
                  name = "rustdesk-server";
                  image = "docker.io/rustdesk/rustdesk-server:1.1.14"; # docker/rustdesk/rustdesk-server@semver-coerced
                  args = [
                    "hbbs"
                    "-r"
                    "localhost:21117"
                  ];
                  securityContext = {
                    allowPrivilegeEscalation = false;
                    readOnlyRootFilesystem = true;
                    capabilities = {
                      drop = [ "ALL" ];
                    };
                  };
                  ports = [
                    { containerPort = 21115; }
                    { containerPort = 21116; }
                    {
                      containerPort = 21116;
                      protocoll = "UDP";
                    }
                    { containerPort = 21118; }
                  ];
                  resources = {
                    requests = {
                      cpu = "200m";
                      memory = "250Mi";
                    };
                    limits = {
                      cpu = "200m";
                      memory = "250Mi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "server-data";
                      mountPath = "/root";
                    }
                  ];
                }
                {
                  name = "rustdesk-relay";
                  image = "docker.io/rustdesk/rustdesk-server:1.1.14"; # docker/rustdesk/rustdesk-server@semver-coerced
                  args = [
                    "hbbr"
                  ];
                  securityContext = {
                    allowPrivilegeEscalation = false;
                    readOnlyRootFilesystem = true;
                    capabilities = {
                      drop = [ "ALL" ];
                    };
                  };
                  ports = [
                    { containerPort = 21117; }
                    { containerPort = 21119; }
                  ];
                  resources = {
                    requests = {
                      cpu = "200m";
                      memory = "250Mi";
                    };
                    limits = {
                      cpu = "200m";
                      memory = "250Mi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "relay-data";
                      mountPath = "/root";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "server-data";
                  persistentVolumeClaim.claimName = rustdesk-server-pvc;
                }
                {
                  name = "relay-data";
                  persistentVolumeClaim.claimName = rustdesk-relay-pvc;
                }
              ];
            };
          };
        };
      };

      services = {
        rustdesk-udp = {
          metadata = {
            inherit namespace;
            name = "rustdesk-udp";
          };
          spec = {
            selector."app.kubernetes.io/name" = "rustdesk";
            ports = [
              {
                name = "udp-port-21116";
                protocol = "UDP";
                port = 21116;
              }
            ];
          };
        };
        rustdesk-tcp = {
          metadata = {
            inherit namespace;
            name = "rustdesk-tcp";
          };
          spec = {
            selector."app.kubernetes.io/name" = "rustdesk";
            ports = [
              {
                name = "tcp-port-21115";
                protocol = "TCP";
                port = 21115;
              }
              {
                name = "tcp-port-21116";
                protocol = "TCP";
                port = 21116;
              }
              {
                name = "tcp-port-21117";
                protocol = "TCP";
                port = 21117;
              }
              # NOTE: this will enable web clients
              # {
              #   name = "tcp-port-21118";
              #   protocol = "TCP";
              #   port = 21118;
              # }
              # {
              #   name = "tcp-port-21119";
              #   protocol = "TCP";
              #   port = 21119;
              # }
            ];
          };
        };
      };

      ingressRouteTCPs = {
        rustdesk-tcp-21115.spec = {
          entryPoints = [
            "tcp-port-21115"
          ];
          routes = [
            {
              match = "HostSNI(`*`)";
              services = [
                {
                  inherit namespace;
                  name = "rustdesk-tcp";
                  port = 21115;
                }
              ];
            }
          ];
        };
        rustdesk-tcp-21116.spec = {
          entryPoints = [
            "tcp-port-21116"
          ];
          routes = [
            {
              match = "HostSNI(`*`)";
              services = [
                {
                  inherit namespace;
                  name = "rustdesk-tcp";
                  port = 21116;
                }
              ];
            }
          ];
        };
        rustdesk-tcp-21117.spec = {
          entryPoints = [
            "tcp-port-21117"
          ];
          routes = [
            {
              match = "HostSNI(`*`)";
              services = [
                {
                  inherit namespace;
                  name = "rustdesk-tcp";
                  port = 21117;
                }
              ];
            }
          ];
        };
      };

      ingressRouteUDPs.rustdesk-udp-21116.spec = {
        entryPoints = [
          "udp-port-21116"
        ];
        routes = [
          {
            services = [
              {
                inherit namespace;
                name = "rustdesk-udp";
                port = 21116;
              }
            ];
          }
        ];
      };

      ciliumNetworkPolicies = {
        rustdesk = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "rustdesk";
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
                        port = "21115";
                        protocol = "TCP";
                      }
                      {
                        port = "21116";
                        protocol = "UDP";
                      }
                      {
                        port = "21116";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [ { } ];
          };
        };
      };
    };
  };
}
