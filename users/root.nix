{ config, lib, ... }:
with lib;

let
  cnfg = config.users.root;
in
{
  options.users.root = {
    enable = mkEnableOption "root user";
  };

  config = mkIf cnfg.enable
    {
      users.users.root = {
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX root" ];
      };
    };
}
