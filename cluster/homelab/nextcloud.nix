{ charts, ... }:
let
  namespace = "nextcloud";
in
{
  applications.nextcloud = {
    inherit namespace;

    createNamespace = true;

    helm.releases.nextcloud = {
      chart = charts.nextcloud.nextcloud;

      values = {
        nextcloud = {
          host = "nextcloud.anderwerse.de";
          trustedDomains = [ "nextcloud.anderwerse.de" ];
          existingSecret = {
            enabled = true;
            secretName = "nextcloud";
          };
        };
        persistence = {
          enabled = true;
          storageClass = "longhorn";
          nextcloudData = {
            enabled = true;
            storageClass = "longhorn";
            size = "20Gi";
          };
        };
        conjob.enabled = true;
        phpClientHttpsFix.enabled = true;

        internalDatabase.enabled = false;
        externalDatabase = {
          enabled = true;
          existingSecret = {
            enabled = true;
            secretName = "database";
          };
        };
        postgresql = {
          enabled = true;
          global.postgresql.auth = {
            existingSecret = "database";
            secretKeys = {
              adminPasswordKey = "db-adminpassword";
              userPasswordKey = "db-password";
              replicationPasswordKey = "db-replicationpassword";
            };
          };
          primary.persistence = {
            enabled = true;
            storageClass = "longhorn";
          };
        };

        livenessProbe = {
          initialDelaySeconds = 120;
          failureThreshold = 15;
        };
        readinessProbe = {
          initialDelaySeconds = 120;
          failureThreshold = 15;
        };
      };
    };

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];

    resources = {
      ingressRoutes = {
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
                  inherit namespace;
                  name = "nextcloud";
                  port = 8080;
                }
              ];
            }
          ];
          tls.secretName = "anderwersede-tls-certificate";
        };
      };
    };
  };
}
