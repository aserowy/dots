{ charts, ... }:
let
  namespace = "immich";
in
{
  applications.immich = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./immich-secrets.sops.yaml)

      ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: immich-library-pvc
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 40Gi
      ''
    ];

    helm.releases.immich = {
      chart = charts.immich-app.immich;

      values.server.controllers.main.containers.main.env = {
        DB_HOSTNAME.value = "immich-pg18-rw.immich.svc.cluster.local";
        DB_DATABASE_NAME.value = "immich";

        DB_USERNAME.value = {
          secretKeyRef = {
            name = "database";
            key = "user";
          };
        };
        DB_PASSWORD.valueFrom = {
          secretKeyRef = {
            name = "database";
            key = "password";
          };
        };

        immich.persistence.library.existingClaim = "immich-library-pvc";

        valkey = {
          enabled = true;
          persistence.data = {
            type = "persistentVolumeClaim";
            size = "1Gi";
            accessMode = "ReadWriteOnce";
            storageClass = "longhorn-nobackup";
          };
        };

        machine-learning = {
          enabled = true;
          cache.data = {
            type = "persistentVolumeClaim";
            size = "10Gi";
            accessMode = "ReadWriteMany";
            storageClass = "longhorn-nobackup";
          };
        };
      };

      resources = {
        # NOTE: patch immich deployment to enable labeled ingress in HAProxy
        deployments.immich.spec.template.metadata.labels."haproxy/ingress" = "allow";

        clusters.immich-pg18 = {
          spec = {
            instances = 1;
            imageCatalogRef = {
              apiGroup = "postgresql.cnpg.io";
              kind = "ClusterImageCatalog";
              name = "trixie";
              major = 18;
            };
            storage.size = "1Gi";

            bootstrap.initdb = {
              owner = "immich";
              database = "immich";
              secret.name = "immich-pg";
            };

            postgresql = {
              shared_preload_libraries = [ "vchord.so" ];
              extensions = [
                {
                  name = "vchord";
                  image.reference = "ghcr.io/tensorchord/vchord-scratch:pg18-v1.1.1";
                  dynamic_library_path = [
                    "/usr/lib/postgresql/18/lib"
                  ];
                  extension_control_path = [
                    "/usr/share/postgresql/18/"
                  ];
                }
              ];
            };

            resources.requests = {
              cpu = "150m";
              memory = "400Mi";
            };

            managed.services.disabledDefaultServices = [
              "ro"
              "r"
            ];
          };
        };

        ingresses.immich = {
          metadata = {
            inherit namespace;
            annotations."cert-manager.io/cluster-issuer" = "azure-acme-issuer";
          };
          spec = {
            ingressClassName = "haproxy";
            tls = [
              {
                hosts = [ "immich.anderwerse.de" ];
                secretName = "immich-tls";
              }
            ];
            rules = [
              {
                host = "immich.anderwerse.de";
                http.paths = [
                  {
                    pathType = "Prefix";
                    path = "/";
                    backend.service = {
                      name = "main";
                      port.number = 2283;
                    };
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
