{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.services.modules.tuigreet;
in
{
  options.services.modules.tuigreet = {
    enable = mkEnableOption "tuigreet";

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

    environment.systemPackages = with pkgs; [
      tuigreet
    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${
            lib.makeBinPath [ pkgs.tuigreet ]
          }/tuigreet --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red --cmd ${cnfg.command}";
          user = "greeter";
        };
      };
    };
  };
}
