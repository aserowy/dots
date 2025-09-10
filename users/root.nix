{ config, lib, ... }:
with lib;

let
  cnfg = config.users.root;
in
{
  options.users.root = {
    enable = mkEnableOption "root user";

    sopsPasswordFilePath = mkOption {
      type = types.str;
      default = "";
      description = ''
        Path to potiential password file in sops.
      '';
    };
  };

  config =
    let
      passwordFilePath =
        if cnfg.sopsPasswordFilePath != "" then
          config.sops.secrets."${cnfg.sopsPasswordFilePath}".path
        else
          null;
    in
    mkIf cnfg.enable {
      users = {
        mutableUsers = false;

        users.root = {
          hashedPassword = null;
          hashedPasswordFile = passwordFilePath;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX serowy"
          ];
        };
      };
    };
}
