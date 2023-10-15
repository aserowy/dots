{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.system.modules.tuigreet;
in
{
  options.system.modules.tuigreet.enable = mkEnableOption "tuigreet";

  config = mkIf cnfg.enable {
    boot.kernelParams = [ "console=tty1" ];

    environment.systemPackages = with pkgs; [
      greetd.tuigreet
    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
      vt = 2;
    };
  };
}
