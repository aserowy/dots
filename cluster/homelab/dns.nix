{ charts, ... }:
{
  applications.dns = {
    namespace = "dns";
    createNamespace = true;

    helm.releases.pihole = {
      chart = charts.mojo2600.pihole;

      values = {
        persistentVolumeClaim = {
          enabled = true;
        };
      };
    };

    yamls = [
      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: pihole-pvc
        spec:
          storageClassName: longhorn
          accessModes:
            - ReadWriteMany
          resources:
            requests:
              storage: 1Gi
      ''
    ];
  };
}
