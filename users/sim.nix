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

        users.sim = {
          # hashedPassword = "";
          hashedPasswordFile = config.sops.secrets."sim/password".path;
          createHome = true;
          extraGroups = if cnfg.dockerGroupMember then extraGroups ++ [ "docker" ] else extraGroups;
          group = "users";
          home = "/home/sim";
          isNormalUser = true;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoChM+zDcZalCCTTF4NTeNyBcrbLBs8b0vBTp/EW1nX sim"
          ];
          shell = pkgs.nushell;
          uid = 1000;
        };
      };

      security.doas = {
        extraRules = [
          {
            users = [ "sim" ];
            keepEnv = true;
            persist = true;
          }
        ];
      };
    };
}
