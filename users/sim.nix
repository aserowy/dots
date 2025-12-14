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
        mutableUsers = false;

        users.sim = {
          inherit extraGroups;

          # hashedPassword = "";
          hashedPasswordFile = config.sops.secrets."sim/password".path;
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
