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
      };
    };
  };
}
