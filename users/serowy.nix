{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.users.serowy;
in
{
  options.users.serowy = {
    enable = mkEnableOption "serowy user";

    dockerGroupMember = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the user gets added to the docker group.
      '';
    };
  };

  config =
    let
      extraGroups = [
        "audio"
        "disk"
        "networkmanager"
        "video"
        "wheel"
      ];
    in
    mkIf cnfg.enable {
      users = {
        mutableUsers = false;

        users.serowy = {
          # hashedPassword = "";
          hashedPasswordFile = config.sops.secrets."serowy/password".path;
          createHome = true;
          extraGroups = if cnfg.dockerGroupMember then extraGroups ++ [ "docker" ] else extraGroups;
          group = "users";
          home = "/home/serowy";
          isNormalUser = true;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX serowy"
          ];
          shell = pkgs.nushell;
          uid = 1000;
        };
      };

      security.doas = {
        extraRules = [
          {
            users = [ "serowy" ];
            keepEnv = true;
            persist = true;
          }
        ];
      };
    };
}
