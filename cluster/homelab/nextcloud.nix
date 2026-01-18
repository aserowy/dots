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
        conjob.enabled = true;
        nextcloud = {
          host = "nextcloud.anderwerse.de";
          trustedDomains = [
            "10.42.0.0/16"
            "nextcloud.anderwerse.de"
          ];
          existingSecret = {
            enabled = true;
            secretName = "nextcloud";
            usernameKey = "username";
            passwordKey = "password";
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
        postgresql = {
          enabled = true;
          global.postgresql.auth = {
            existingSecret = "database";
            secretKeys = {
              adminPasswordKey = "admin_password";
              userPasswordKey = "user_password";
              replicationPasswordKey = "replication_password";
            };
          };
          primary.persistence = {
            enabled = true;
            storageClass = "longhorn";
          };
        };
        livenessProbe.initialDelaySeconds = 90;
        readinessProbe.initialDelaySeconds = 90;
      };
    };

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];

  };
}
