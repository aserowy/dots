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
        mutableUsers = false;

        users.music = {
          inherit extraGroups;

          # hashedPassword = "";
          hashedPasswordFile = config.sops.secrets."music/password".path;
          createHome = true;
          group = "users";
          home = "/home/music";
          isNormalUser = true;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX music"
          ];
          shell = pkgs.nushell;
          uid = 1000;
        };
      };
    };
}
