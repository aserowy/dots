{ charts, ... }:
let
  namespace = "certificates";
in
{
  applications.certificates = {
    inherit namespace;

    createNamespace = true;

    helm.releases = {
      cert-manager = {
        chart = charts.jetstack.cert-manager;

        values = {
          crds.enabled = true;

          replicaCount = 2;
          webhook.replicaCount = 3;
          cainjector.replicaCount = 2;
        };
      };
    };

    yamls = [
      (builtins.readFile ./certificates-secrets.sops.yaml)
    ];

    # NOTE: https://cert-manager.io/docs/installation/best-practice/#network-requirements
    resources = {
      clusterIssuers = {
        azure-acme-issuer.spec.acme = {
          email = "alexander.serowy+dots@proton.me";
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

      ciliumNetworkPolicies = {
        cainjector = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "cainjector";
            };
            ingress = [
              # NOTE: metrics collector must get unblocked here
              { }
            ];
            egress = [
              {
                toEntities = [
                  "host"
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

        cert-manager = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "cert-manager";
            };
            ingress = [
              # NOTE: metrics collector must get unblocked here
              {
                fromEntities = [ "host" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "9403";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [
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
                toEntities = [
                  "world"
                ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "443";
                        protocol = "TCP";
                      }
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

        webhook = {
          apiVersion = "cilium.io/v2";
          kind = "CiliumNetworkPolicy";
          metadata = {
            inherit namespace;
          };
          spec = {
            endpointSelector.matchLabels = {
              "app.kubernetes.io/name" = "webhook";
            };
            ingress = [
              # NOTE: metrics collector must get unblocked here
              {
                fromEntities = [ "host" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "6080";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                fromEntities = [ "kube-apiserver" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "443";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
              {
                # NOTE: startupapicheck node
                fromEntities = [ "remote-node" ];
                toPorts = [
                  {
                    ports = [
                      {
                        port = "10250";
                        protocol = "TCP";
                      }
                    ];
                  }
                ];
              }
            ];
            egress = [
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
      };
    };
  };
}
