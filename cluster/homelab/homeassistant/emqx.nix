{ application, charts, ... }:
{
  applications."${application}" = {
    helm.releases = {
      # FIX: replace with nixhelm entry after pr merged
      # chart = charts.emqx.emqx;
      chart = {
        repo = "https://repos.emqx.io/charts/";
        chart = "emqx";
        version = "5.8.6";
        chartHash = "sha256-no99jOD0yiBoShfBFQK9MZL8Yu9WHVz0iMPXAPi9q3w=";
      };

      values = { };
    };

    resources = {
    };
  };
}
