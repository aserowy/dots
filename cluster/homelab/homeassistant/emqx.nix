{
  application,
  charts,
  ...
}:
{
  applications."${application}" = {
    helm.releases.emqx = {
      chart = charts.emqx.emqx;

      values = { };
    };

    resources = {
    };
  };
}
