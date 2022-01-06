{ config, pkgs, lib, ... }:
{
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
}
