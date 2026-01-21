{ charts, ... }:
let
  namespace = "loadbalancer";
in
{
  applications.loadbalancer = {
    inherit namespace;

    createNamespace = true;

    helm.releases = {
      traefik = {
        chart = charts.traefik.traefik;

        values = {
          ports = {
            web = {
              exposedPort = 80;
              port = 8000;
              http.redirections.entrypoint = {
                to = "websecure";
                scheme = "https";
                permanent = true;
              };
            };
            websecure = {
              exposedPort = 443;
              port = 8443;
            };
            tcp-port-21115 = {
              expose.default = true;
              exposedPort = 21115;
              port = 21115;
            };
            udp-port-21116 = {
              expose.default = true;
              exposedPort = 21116;
              port = 21116;
              protocol = "UDP";
            };
            tcp-port-21116 = {
              expose.default = true;
              exposedPort = 21116;
              port = 21116;
            };
            tcp-port-21117 = {
              expose.default = true;
              exposedPort = 21117;
              port = 21117;
            };
          };
          additionalArguments = [
            "--log.level=DEBUG"
          ];
          commonLabels = {
            "app.kubernetes.io/role" = "entrypoint";
          };
          service = {
            annotations = {
              "lbipam.cilium.io/sharing-cross-namespace" = "*";
              "lbipam.cilium.io/sharing-key" = "default-ippool";
            };
          };
        };
      };
    };

    yamls = [
      (builtins.readFile ./loadbalancer-secrets.sops.yaml)
    ];

    resources = {
      issuers = {
        azure-acme-issuer.spec.acme = {
          email = "serowy@hotmail.com";
          server = "https://acme-v02.api.letsencrypt.org/directory";
          privateKeySecretRef.name = "azure-issuer-account-key";
          solvers = [
            {
              dns01 = {
                azureDNS = {
                  clientID = "e48f89f8-a7ac-45c6-8d9c-10edbf3365cb";
                  clientSecretSecretRef = {
                    name = "azure-acme-environment";
                    key = "AZURE_CLIENT_SECRET";
                  };
                  subscriptionID = "b0f74bb3-5530-4ad4-a307-dc6a96b371c0";
                  tenantID = "fe7eb9da-a96c-4ffd-8fe0-fd1ec4f77439";
                  resourceGroupName = "rg_homelab";
                  hostedZoneName = "anderwerse.de";
                };
              };
            }
          ];
        };
      };

      certificates = {
        anderwersede-tls-certificate.spec = {
          secretName = "anderwersede-tls-certificate";
          issuerRef = {
            name = "azure-acme-issuer";
            kind = "Issuer";
          };
          duration = "2160h";
          renewBefore = "720h";
          dnsNames = [
            "*.anderwerse.de"
          ];
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
                  namespace = "adguard";
                  name = "adguard-dashboard";
                  port = 3000;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        argocd-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`argo.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  name = "argocd-server";
                  namespace = "argocd";
                  port = 80;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        cilium-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`cni.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  name = "hubble-ui";
                  namespace = "kube-system";
                  port = 80;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        grafana-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`cluster.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  name = "kube-prometheus-stack-grafana";
                  namespace = "monitoring";
                  port = 80;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        homeassistant-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`homeassistant.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  namespace = "homeassistant";
                  name = "homeassistant";
                  port = 8123;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        longhorn-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`csi.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  name = "longhorn-frontend";
                  namespace = "longhorn-system";
                  port = 80;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
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
                  namespace = "nextcloud";
                  name = "nextcloud";
                  port = 8080;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
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
                  namespace = "paperless";
                  name = "paperless";
                  port = 8000;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        traefik-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`traefik.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  name = "api@internal";
                  kind = "TraefikService";
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
        zigbee2mqtt-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`zigbee.anderwerse.de`)";
              kind = "Rule";
              services = [
                {
                  namespace = "homeassistant";
                  name = "zigbee2mqtt";
                  port = 8080;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
      };

      ciliumClusterwideNetworkPolicies = {
        traefik = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumClusterwideNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector = {
              matchLabels = {
                "io.kubernetes.pod.namespace" = "loadbalancer";
                "app.kubernetes.io/name" = "traefik";
              };
            };
            ingress = [
              {
                fromEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/component" = "app";
                    };
                  }
                ];
              }
              {
                fromEntities = [
                  "host"
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8080";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEntities = [
                  "world"
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8000";
                        protocol = "TCP";
                      }
                      {
                        port = "8443";
                        protocol = "TCP";
                      }
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
                      {
                        port = "21117";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [
              {
                toEndpoints = [
                  {
                    matchLabels = {
                      "app.kubernetes.io/component" = "app";
                    };
                  }
                ];
              }
              {
                toEntities = [
                  "kube-apiserver"
                ];
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
                      "io.kubernetes.pod.namespace" = "argocd";
                      "app.kubernetes.io/name" = "argocd-server";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8080";
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
                      "io.kubernetes.pod.namespace" = "monitoring";
                      "app.kubernetes.io/name" = "grafana";
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
                      "io.kubernetes.pod.namespace" = "longhorn-system";
                      "app" = "longhorn-ui";
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
                toEndpoints = [
                  {
                    matchLabels = {
                      "io.kubernetes.pod.namespace" = "kube-system";
                      "app.kubernetes.io/name" = "hubble-ui";
                    };
                  }
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "8081";
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
