{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.users.deploy;
in
{
  options.users.deploy = {
    enable = mkEnableOption "deploy user";
  };

  config = mkIf cnfg.enable
    {
      users = {
        groups.deploy = { };

        users.deploy = {
          isSystemUser = true;
          group = "deploy";
          shell = pkgs.bash;

          openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX serowy" ];
        };
      };

      security.sudo.extraRules = [
        {
          groups = [ "deploy" ];
          commands = [
            {
              command = "/nix/store/*/bin/switch-to-configuration";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix-store";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix-env";
              options = [ "NOPASSWD" ];
            }
            {
              command = ''/bin/sh -c "readlink -e /nix/var/nix/profiles/system || readlink -e /run/current-system"'';
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix-collect-garbage";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
}
