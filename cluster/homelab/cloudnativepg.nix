{ charts, ... }:
let
  namespace = "cnpg-system";
in
{
  applications.cloudnativepg = {
    inherit namespace;
    createNamespace = true;

    syncPolicy.syncOptions.serverSideApply = true;

    helm.releases.cloudnativepg = {
      chart = charts.cloudnative-pg.cloudnative-pg;

      values = {
        resources.requests = {
          cpu = "100m";
          memory = "200Mi";
        };
      };
    };

    resources.clusterImageCatalogs.trixie.spec.images = [
      {
        major = 16;
        image = "ghcr.io/cloudnative-pg/postgresql:16.11-standard-trixie";
      }
      {
        major = 17;
        image = "ghcr.io/cloudnative-pg/postgresql:17.7-standard-trixie";
      }
      {
        major = 18;
        image = "ghcr.io/cloudnative-pg/postgresql:18.1-standard-trixie";
      }
    ];
  };
}
