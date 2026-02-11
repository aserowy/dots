{ ... }:
let
  namespace = "adguard";
in
{
  applications.adguard = {
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
      statefulSets = {
        adguard = {
          apiVersion = "apps/v1";
          metadata = {
            inherit namespace;
            name = "adguard";
          };
          spec = {
            replicas = 1;
            selector.matchLabels."app.kubernetes.io/name" = "adguard";
            template = {
              metadata.labels = {
                "app.kubernetes.io/name" = "adguard";
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
                    name = "copy-base-config";
                    image = "busybox:1.37.0"; # docker/busybox@semver-coerced
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
                    image = "docker.io/adguard/adguardhome:v0.107.71"; # docker/adguard/adguardhome@semver
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
                    resources.requests = {
                      cpu = "50m";
                      memory = "200Mi";
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
            selector."app.kubernetes.io/name" = "adguard";
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
              "lbipam.cilium.io/sharing-key" = "default";
            };
            labels = {
              "cilium/ippool" = "default";
            };
          };
          spec = {
            type = "LoadBalancer";
            selector."app.kubernetes.io/name" = "adguard";
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

      ingresses.adguard = {
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
              hosts = [ "adguard.anderwerse.de" ];
              secretName = "adguard-tls";
            }
          ];
          rules = [
            {
              host = "adguard.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "adguard-dashboard";
                    port.number = 3000;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies.adguard = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector = {
            matchLabels = {
              "app.kubernetes.io/name" = "adguard";
            };
          };
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
                      port = "3000";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
            {
              fromEntities = [ "world" ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "53";
                      protocol = "TCP";
                    }
                    {
                      port = "53";
                      protocol = "UDP";
                    }
                    {
                      port = "67";
                      protocol = "UDP";
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
    };
  };
}
