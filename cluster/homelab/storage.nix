{ charts, ... }:
let
  namespace = "longhorn-system";
in
{
  applications.storage = {
    inherit namespace;

    createNamespace = true;

    helm.releases.longhorn = {
      chart = charts.longhorn.longhorn;

      values = {
        defaultBackupStore = {
          backupTarget = "azblob://backup@core.windows.net/";
          backupTargetCredentialSecret = "longhorn-azblob-secret";
          # NOTE: set intervall to two days: 60*60*24*2
          pollInterval = "172800";
        };

        defaultSettings = {
          concurrentAutomaticEngineUpgradePerNodeLimit = "1";
          replicaAutoBalance = "best-effort";
          storageOverProvisioningPercentage = "75";
        };

        persistence = {
          # NOTE: better performance and less strain on network
          defaultClassReplicaCount = 2;
          reclaimPolicy = "Retain";
          recurringJobSelector = {
            enable = true;
            jobList = "[{\"name\":\"backup\",\"isGroup\":true}]";
          };
        };

        # NOTE: must be disabled for helm deployments inside argo cd
        preUpgradeChecker.jobEnabled = false;
      };
    };

    resources = {
      # NOTE: patch longhorn ui deployment to enable labeled ingress in HAProxy
      deployments.longhorn-ui.spec.template.metadata.labels."haproxy/egress" = "allow";

      ingresses.longhorn = {
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
              hosts = [ "longhorn.cluster.anderwerse.de" ];
              secretName = "longhorn-tls";
            }
          ];
          rules = [
            {
              host = "longhorn.cluster.anderwerse.de";
              http.paths = [
                {
                  pathType = "Prefix";
                  path = "/";
                  backend.service = {
                    name = "longhorn-frontend";
                    port.number = 80;
                  };
                }
              ];
            }
          ];
        };
      };

      ciliumNetworkPolicies.longhorn-ui = {
        apiVersion = "cilium.io/v2";
        kind = "CiliumNetworkPolicy";
        metadata = {
          inherit namespace;
        };
        spec = {
          endpointSelector = {
            matchLabels = {
              "app" = "longhorn-ui";
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
                    "app" = "longhorn-manager";
                  };
                }
              ];
              toPorts = [
                {
                  ports = [
                    {
                      port = "9500";
                      protocol = "TCP";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };

      storageClasses.longhorn-nobackup = {
        metadata.name = "longhorn-nobackup";
        provisioner = "driver.longhorn.io";
        allowVolumeExpansion = true;
        parameters = {
          numberOfReplicas = "2";
          staleReplicaTimeout = "30";
          fromBackup = "";
          fsType = "ext4";
          dataLocality = "disabled";
          unmapMarkSnapChainRemoved = "ignored";
          disableRevisionCounter = "true";
          dataEngine = "v1";
        };
      };
    };

    yamls = [
      (builtins.readFile ./storage-secrets.sops.yaml)

      # NOTE: backup
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: longhorn-volume-snapshot
          namespace: longhorn-system
        spec:
          name: longhorn-volume-snapshot
          task: snapshot
          concurrency: 1
          cron: 0 0 * * *
          retain: 4
          groups:
          - backup
      ''
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: longhorn-volume-backup
          namespace: longhorn-system
        spec:
          name: longhorn-volume-backup
          task: backup
          concurrency: 1
          cron: 0 3 * * 2,5
          retain: 8
          parameters:
            full-backup-interval: "4"
          groups:
            - backup
      ''
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: longhorn-system-backup
          namespace: longhorn-system
        spec:
          name: longhorn-system-backup
          task: system-backup
          concurrency: 1
          cron: 0 3 * * 5
          retain: 1
          parameters:
            volume-backup-policy: disabled
      ''

      # NOTE: cleaning resources
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: longhorn-filesystem-trim
          namespace: longhorn-system
        spec:
          name: longhorn-filesystem-trim
          task: filesystem-trim
          concurrency: 1
          cron: 0 0 * * *
          groups:
            - default
            - backup
      ''
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: longhorn-snapshot-cleanup
          namespace: longhorn-system
        spec:
          name: longhorn-snapshot-cleanup
          task: snapshot-cleanup
          concurrency: 1
          cron: 0 0 * * *
          groups:
            - backup
      ''

      # NOTE: patching path to enable longhorn on nixos
      ''
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: longhorn-nixos-path
          namespace: longhorn-system
        data:
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin
      ''
      ''
        apiVersion: kyverno.io/v1
        kind: ClusterPolicy
        metadata:
          name: longhorn-add-nixos-path
          annotations:
            policies.kyverno.io/title: Add Environment Variables from ConfigMap
            policies.kyverno.io/subject: Pod
            policies.kyverno.io/category: Other
            policies.kyverno.io/description: >-
              Longhorn invokes executables on the host system, and needs
              to be aware of the host systems PATH. This modifies all
              deployments such that the PATH is explicitly set to support
              NixOS based systems.
        spec:
          rules:
            - name: add-env-vars
              match:
                resources:
                  kinds:
                    - Pod
                  namespaces:
                    - longhorn-system
              mutate:
                patchStrategicMerge:
                  spec:
                    initContainers:
                      - (name): "*"
                        envFrom:
                          - configMapRef:
                              name: longhorn-nixos-path
                    containers:
                      - (name): "*"
                        envFrom:
                          - configMapRef:
                              name: longhorn-nixos-path
      ''
    ];

    # NOTE: https://github.com/longhorn/longhorn/discussions/10786
    ignoreDifferences = {
      "engineimages.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
      "engines.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
      "instancemanagers.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
      "nodes.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
      "replicas.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
      "settings.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
      "volumes.longhorn.io" = {
        group = "apiextensions.k8s.io";
        kind = "CustomResourceDefinition";
        jsonPointers = [ "/spec/preserveUnknownFields" ];
      };
    };
  };
}
