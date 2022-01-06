{ config, pkgs, ... }:
{
  environment = {
    etc = {
      "i3/scripts".source = ./src/scripts;
    };

    pathsToLink = [ "/libexec" ];
  };

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      configFile = ./src/config;
      extraPackages = with pkgs; [
        feh
        jq
        pv
      ];
      package = pkgs.i3-gaps;
    };
  };
}
