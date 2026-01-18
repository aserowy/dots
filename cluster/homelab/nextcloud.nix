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
        # conjob.enabled = true;
        internalDatabase.enabled = false;
        nextcloud = {
          # existingSecret = {
          #   enabled = true;
          #   secretName = "nextcloud";
          #   usernameKey = "username";
          #   passwordKey = "password";
          # };
          # host = "nextcloud.anderwerse.de";
          # trustedDomains = [ "nextcloud.anderwerse.de" ];
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
          # global.postgresql.auth = {
          #   existingSecret = "database";
          #   secretKeys = {
          #     adminPasswordKey = "admin_password";
          #     userPasswordKey = "user_password";
          #     replicationPasswordKey = "replication_password";
          #   };
          # };
          primary.persistence = {
            enabled = true;
            storageClass = "longhorn";
          };
        };
        livenessProbe.initialDelaySeconds = 30;
        readinessProbe.initialDelaySeconds = 30;
      };
    };

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];

  };
}
