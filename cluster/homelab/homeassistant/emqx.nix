{ application, charts, ... }:
{
  applications."${application}" = {
    helm.releases = {
    };

    resources = {
    };
  };
}
