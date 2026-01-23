{ charts, ... }:
{
  applications.secrets = {
    namespace = "secrets";
    createNamespace = true;

    helm.releases.sops-secrets-operator = {
      chart = charts.isindir.sops-secrets-operator;

      values = {
        secretsAsFiles = [
          {
            name = "keys";
            mountPath = "/var/lib/sops/age";
            # NOTE: Secret created manually on host.
            secretName = "age-keys";
          }
        ];
        extraEnv = [
          {
            name = "SOPS_AGE_KEY_FILE";
            value = "/var/lib/sops/age/key.txt";
          }
        ];
      };
    };
  };
}
