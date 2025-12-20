{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.users.sim;
in
{
  options.users.sim = {
    enable = mkEnableOption "sim user";
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
      users = {
        users.sim = {
          inherit extraGroups;

          initialPassword = "changeme!";
          createHome = true;
          group = "users";
          home = "/home/sim";
          isNormalUser = true;
          shell = pkgs.nushell;
          uid = 1000;
        };
      };
    };
}
