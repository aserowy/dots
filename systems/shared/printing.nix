{ pkgs, ... }:
{
  # INFO: configuration reachable under http://localhost:631/
  services = {
    printing = {
      enable = true;
      drivers = [
        pkgs.foo2zjs
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
