{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.collabora = {
      chart = charts.collabora-online.collabora-online;

      values = {
        # NOTE: without dynamic load hpa is not necessary
        autoscaling.enabled = false;
        replicaCount = 2;

        collabora = {
          aliasgroups = [
            { host = "https://collabora.anderwerse.de:443"; }
          ];
          existingSecret = {
            enabled = true;
            secretName = "collabora";
          };
          proofKeysSecretRef = "collabora-proof-key";
        };
        resources = {
          requests = {
            cpu = "2000m";
            memory = "2Gi";
          };
          limits = {
            cpu = "4000m";
            memory = "6Gi";
          };
        };
      };
    };
  };
}
