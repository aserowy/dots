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
      };
    };

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];

  };
}
