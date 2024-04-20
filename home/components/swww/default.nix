{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.swww;

  # FIX: pin to 0.9.1 till https://github.com/LGFae/swww/issues/275 is fixed
  system = "x86_64-linux";

  pkgsPinned = import
    (builtins.fetchGit {
      # Descriptive name to make the store path easier to identify
      name = "my-old-revision";
      url = "https://github.com/NixOS/nixpkgs/";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "e89cf1c932006531f454de7d652163a9a5c86668";
    })
    {
      inherit system;
    };
in
{
  options.home.components.swww = {
    enable = mkEnableOption "swww";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swww script gets added to sways config.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swww script gets added to hyprland config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file.".config/swww/wallpaper.sh".source = ./swww-wallpaper.sh;

      packages = with pkgsPinned; [
        swww
      ];
    };

    home.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
      # Start swww daemon and cycle through random wallpaper
      exec swww-daemon
      exec bash ~/.config/swww/wallpaper.sh ~/onedrive/Wallpapers/
    '';

    home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
      # Start swww daemon and cycle through random wallpaper
      exec-once = swww-daemon
      exec-once = bash ~/.config/swww/wallpaper.sh ~/onedrive/Wallpapers/
    '';
  };
}
