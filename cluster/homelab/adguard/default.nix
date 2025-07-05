{ ... }:
let
  application = "adguard";
  namespace = application;
in
{
  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./adguard-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: adguard-work-pvc
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 5Gi
      ''
    ];

    resources = {
      deployments = {
        adguard = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            inherit namespace;
            name = "adguard";
          };
          spec = {
            replicas = 1;
            selector = {
              matchLabels = {
                app = "adguard";
              };
            };
            strategy = {
              type = "Recreate";
            };
            template = {
              metadata = {
                labels = {
                  app = "adguard";
                };
              };
              spec = {
                securityContext = {
                  seccompProfile = {
                    type = "RuntimeDefault";
                  };
                };
                initContainers = [
                  {
                    name = "copy-base-config";
                    # TODO: add version tag
                    image = "busybox";
                    command = [
                      "/bin/sh"
                      "-c"
                      ''
                        cp -v /tmp/adguardhome.yaml /opt/adguardhome/conf/AdGuardHome.yaml
                        cat /tmp/users.yaml >> /opt/adguardhome/conf/AdGuardHome.yaml
                      ''
                    ];
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                      capabilities = {
                        drop = [ "ALL" ];
                      };
                    };
                    volumeMounts = [
                      {
                        name = "config";
                        mountPath = "/tmp/adguardhome.yaml";
                        subPath = "adguardhome.yaml";
                      }
                      {
                        name = "users";
                        mountPath = "/tmp/users.yaml";
                        subPath = "users.yaml";
                      }
                      {
                        name = "config-folder";
                        mountPath = "/opt/adguardhome/conf";
                      }
                    ];
                  }
                ];
                containers = [
                  {
                    name = "adguard";
                    image = "docker.io/adguard/adguardhome:v0.107.63"; # docker/adguard/adguardhome@semver
                    securityContext = {
                      allowPrivilegeEscalation = false;
                      readOnlyRootFilesystem = true;
                    };
                    ports = [
                      {
                        name = "dns-tcp";
                        containerPort = 53;
                        protocol = "TCP";
                      }
                      {
                        name = "dns-udp";
                        containerPort = 53;
                        protocol = "UDP";
                      }
                      {
                        name = "dhcp";
                        containerPort = 67;
                        protocol = "UDP";
                      }
                      {
                        name = "http";
                        containerPort = 3000;
                        protocol = "TCP";
                      }
                    ];
                    resources = {
                      requests = {
                        cpu = "50m";
                        memory = "128Mi";
                      };
                      limits = {
                        cpu = "500m";
                        memory = "256Mi";
                      };
                    };
                    volumeMounts = [
                      {
                        name = "config-folder";
                        mountPath = "/opt/adguardhome/conf";
                      }
                      {
                        name = "work-folder";
                        mountPath = "/opt/adguardhome/work";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "config";
                    configMap = {
                      name = "adguard-cm";
                    };
                  }
                  {
                    name = "users";
                    secret = {
                      secretName = "adguard-users";
                    };
                  }
                  {
                    name = "config-folder";
                    emptyDir = { };
                  }
                  {
                    name = "work-folder";
                    persistentVolumeClaim = {
                      claimName = "adguard-work-pvc";
                    };
                  }
                ];
              };
            };
          };
        };
      };

      configMaps = {
        adguard-cm = {
          metadata = {
            inherit namespace;
            name = "adguard-cm";
          };
          data = {
            "adguardhome.yaml" = (builtins.readFile ./adguard-config.yaml);
          };
        };
      };

      services = {
        adguard-dashboard = {
          metadata = {
            inherit namespace;
            name = "adguard-dashboard";
          };
          spec = {
            selector = {
              app = "adguard";
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
        adguard-dns = {
          metadata = {
            inherit namespace;
            name = "adguard-dns";
            annotations = {
              "lbipam.cilium.io/sharing-cross-namespace" = "*";
              "lbipam.cilium.io/sharing-key" = "default-ippool";
            };
            labels = {
              "homelab/loadbalancer" = "entrypoint";
            };
          };
          spec = {
            type = "LoadBalancer";
            selector = {
              app = "adguard";
            };
            ports = [
              {
                name = "dns-tcp";
                protocol = "TCP";
                port = 53;
              }
              {
                name = "dns-udp";
                protocol = "UDP";
                port = 53;
              }
              {
                name = "dhcp";
                protocol = "UDP";
                port = 67;
              }
            ];
          };
        };
      };

      ingressRoutes = {
        adguard-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`dns.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  inherit namespace;
                  name = "adguard-dashboard";
                  port = 3000;
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
