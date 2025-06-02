{ charts, ... }:
{
  applications.dns = {
    namespace = "dns";
    createNamespace = true;

    helm.releases.pihole = {
      chart = charts.mojo2600.pihole;
    };
  };
}
