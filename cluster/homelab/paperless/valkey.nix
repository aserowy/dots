{
  application,
  namespace,
  charts,
  ...
}:
{
  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    helm.releases.valkey = {
      chart = charts.valkey.valkey;

      values = {
        auth = {
          enabled = true;
          usersExistingSecret = "valkey-users";
          aclUsers = {
            default.permissions = "~* &* +@all";
            paperless.permissions = "~* &* +@all";
          };
        };

        dataStorage = {
          enabled = true;
          className = "longhorn-nobackup";
          requestedSize = "2Gi";
        };
      };
    };
  };
}
