{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.users.music;
in
{
  options.users.music = {
    enable = mkEnableOption "music user";
  };

  config =
    let
      extraGroups = [
        "audio"
        "disk"
        "networkmanager"
        "video"
      ];
    in
    mkIf cnfg.enable {
      users = {
        users.music = {
          inherit extraGroups;

          initialPassword = "changeme!";
          createHome = true;
          group = "users";
          home = "/home/music";
          isNormalUser = true;
          shell = pkgs.nushell;
          uid = 1000;
        };
      };
    };
}
