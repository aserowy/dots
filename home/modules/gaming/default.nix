{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.gaming;
in
{
  options.home.modules.gaming = {
    enable = mkEnableOption "gaming";
  };

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      gamescope

      (lutris.override {
        extraPkgs = pkgs: [
          winePackages.staging
          wine64Packages.staging
        ];
      })

      # NOTE: xbox controller support
      xboxdrv
    ];

    xdg.desktopEntries = {
      steam = {
        name = "GameScoped Steam";
        genericName = "Steam";
        exec = "${pkgs.gamescope}/bin/gamescope -w 3440 -h 1440 --steam -- steam -pipewire-dmabuf";
        icon = "steam";
        categories = [ "Game" ];
      };

      "net.lutris.Lutris" = {
        name = "GameScoped Lutris";
        genericName = "Lutris";
        exec = "${pkgs.gamescope}/bin/gamescope -w 3440 -h 1440 -- lutris";
        icon = "lutris";
        categories = [ "Game" ];
      };
    };
  };
}
