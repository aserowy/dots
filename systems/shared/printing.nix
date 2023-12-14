{ config, pkgs, ... }:
{
  services = {
    printing = {
      enable = true;
      browsing = true;
      browsedConf = ''
        BrowseDNSSDSubTypes _cups,_print
        BrowseLocalProtocols all
        BrowseRemoteProtocols all
        CreateIPPPrinterQueues All

        BrowseProtocols all
      '';
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
