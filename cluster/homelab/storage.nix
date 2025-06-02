{ charts, ... }:
{
  applications.storage = {
    namespace = "longhorn-system";
    createNamespace = true;

    helm.releases.longhorn = {
      chart = charts.longhorn.longhorn;

      values = {
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
      # NOTE: cleaning resources
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: filesystem-trim
          namespace: longhorn-system
        spec:
          concurrency: 1
          cron: 0 0 * * *
          name: filesystem-trim
          task: filesystem-trim
          groups:
            - default
      ''
      ''
        apiVersion: longhorn.io/v1beta2
        kind: RecurringJob
        metadata:
          name: snapshot-cleanup
          namespace: longhorn-system
        spec:
          concurrency: 1
          cron: 12 0 * * *
          groups:
            - default
          name: snapshot-cleanup
          task: snapshot-cleanup
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
