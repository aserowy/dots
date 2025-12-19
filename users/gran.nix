{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.users.gran;
in
{
  options.users.gran = {
    enable = mkEnableOption "gran user";
  };

  config =
    let
      extraGroups = [
        "audio"
        "disk"
        "lpadmin"
        "networkmanager"
        "video"
        "wheel"
      ];
    in
    mkIf cnfg.enable {
      security.pam.services.gran.kwallet.enable = true;

      users = {
        users.gran = {
          inherit extraGroups;

          initialPassword = "changeme!";
          createHome = true;
          group = "users";
          home = "/home/gran";
          isNormalUser = true;
          shell = pkgs.nushell;
          uid = 1000;
        };
      };
    };
}
