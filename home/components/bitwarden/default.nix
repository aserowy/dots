{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.bitwarden;

  configure = pkgs.writeText "configure-bitwarden.nu" "
    # touch /home/serowy/testtouch
  ";
in
{
  options.home.components.bitwarden.enable = mkEnableOption "bitwarden";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        bitwarden-desktop
      ];

      modules.nushell.appendedConfig = ''
        $env.SSH_AUTH_SOCK = ($nu.home-dir | path join ".bitwarden-ssh-agent.sock")
      '';

      activation.bitwarden = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.nushell}/bin/nu ${configure}
      '';
    };
  };
}
