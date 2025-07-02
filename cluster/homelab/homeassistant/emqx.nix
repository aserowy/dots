{
  application,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.emqx = {
      chart = charts.emqx.emqx;

      values = {
        persistence = {
          enable = true;
          storageClass = "longhorn";
          size = "1Gi";
        };
      };
    };
  };
}
