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
        autoscaling.enabled = false;
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
          limits = {
            cpu = "500m";
            memory = "1Gi";
          };
          requests = {
            cpu = "100m";
            memory = "128Mi";
          };
        };
      };
    };
  };
}
