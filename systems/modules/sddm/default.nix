{
  config,
  lib,
  # pkgs,
  ...
}:
with lib;

let
  cnfg = config.services.modules.sddm;
in
{
  options.services.modules.sddm = {
    enable = mkEnableOption "sddm";

    command = mkOption {
      type = types.str;
      default = "";
      description = ''
        Command that gets executed after successful authentification.
      '';
    };
  };

  config = mkIf cnfg.enable {
    boot.kernelParams = [ "console=tty1" ];

    services.displayManager = {
      defaultSession = cnfg.command;
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
