{ charts, ... }:
{
  applications.storage = {
    namespace = "longhorn-system";
    createNamespace = true;

    helm.releases.longhorn = {
      chart = charts.longhorn.longhorn;

      values = {
        preUpgradeChecker.jobEnabled = false;
      };
    };
  };
}
