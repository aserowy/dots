{ charts, ... }:
{
  applications.policies = {
    namespace = "policies";
    createNamespace = true;

    helm.releases.sops-policies-operator = {
      chart = charts.kyverno.kyverno;

      values = {
      };
    };
  };
}
