{ charts, ... }:
{
  applications.policies = {
    namespace = "policies";
    createNamespace = true;

    annotations = {
      serverSideDiff = "true";
      includeMutationWebhook = "true";
    };

    syncPolicy.syncOptions.serverSideApply = true;

    helm.releases.kyverno = {
      chart = charts.kyverno.kyverno;

      values = {
      };
    };
  };
}
