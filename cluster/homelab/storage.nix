{ charts, ... }:
{
  applications.storage = {
    namespace = "longhorn-system";
    createNamespace = true;

    helm.releases.longhorn = {
      chart = charts.longhorn.longhorn;

      values = {
        defaultBackupStore = {
          backupTarget = "azblob://sahomelab71283.blob.core.windows.net/homelab-backup/";
          backupTargetCredentialSecret = "longhorn-azblob-secret";
        };

        persistence = {
          reclaimPolicy = "Retain";

          # NOTE: default is 3, but running it on single node currently
          defaultClassReplicaCount = 1;
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
          name: default-snapshot-daily
          namespace: longhorn-system
        spec:
          name: default-snapshot-daily
          task: snapshot
          concurrency: 1
          cron: 0 0 * * *
          retain: 7
          groups:
          - default
      ''
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: default-backup
          namespace: longhorn-system
        spec:
          name: default-backup
          task: backup
          concurrency: 1
          cron: 0 3 * * 3,5
          retain: 8
          parameters:
            full-backup-interval: "4"
          groups:
            - default
      ''

      # NOTE: cleaning resources
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: default-filesystem-trim
          namespace: longhorn-system
        spec:
          name: default-filesystem-trim
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
          name: default-snapshot-cleanup
          namespace: longhorn-system
        spec:
          name: default-snapshot-cleanup
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
  };
}
