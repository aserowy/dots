{ charts, ... }:
{
  applications.storage = {
    namespace = "longhorn-system";
    createNamespace = true;

    helm.releases.longhorn = {
      chart = charts.longhorn.longhorn;

      values = {
        # NOTE: must be disabled for helm deployments inside argo cd
        preUpgradeChecker.jobEnabled = false;
      };
    };
  };
}
