{ charts, ... }:
{
  applications.storage = {
    namespace = "longhorn-system";
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

        persistence = {
          reclaimPolicy = "Retain";

          # NOTE: default is 3, but running it on two node cluster
          defaultClassReplicaCount = 2;
        };

        # NOTE: must be disabled for helm deployments inside argo cd
        preUpgradeChecker.jobEnabled = false;
      };
    };

    resources = {
      ingressRoutes = {
        longhorn-dashboard-route.spec = {
          entryPoints = [
            "websecure"
          ];
          routes = [
            {
              match = "Host(`longhorn.anderwerse.de`)";
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
          - default
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
            - default
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
            - default
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
