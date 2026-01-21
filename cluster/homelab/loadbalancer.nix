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
      clusterIssuers = {
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
