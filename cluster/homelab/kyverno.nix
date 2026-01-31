{ charts, ... }:
{
  applications.kyverno = {
    namespace = "kyverno";
    createNamespace = true;

    annotations = {
      serverSideDiff = "true";
      includeMutationWebhook = "true";
    };

    syncPolicy.syncOptions.serverSideApply = true;

    helm.releases.kyverno = {
      chart = charts.kyverno.kyverno;
    };
  };
}
