{ config, pkgs, ... }:
{
  services.clamav = {
    updater.enable = true;

    daemon = {
      enable = true;
      settings = {
        ConcurrentDatabaseReload = false;
      };
    };
  };
}
