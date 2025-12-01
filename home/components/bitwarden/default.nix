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

      activation.bitwarden = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.nushell}/bin/nu ${configure}
      '';
    };
  };
}
