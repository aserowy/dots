{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.swww;
in
{
  options.home.components.swww = {
    enable = mkEnableOption "swww";

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the swww script gets added to niris config.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file.".config/swww/wallpaper.sh".source = ./swww-wallpaper.sh;

      packages = with pkgs; [
        swww
      ];
    };

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "swww-daemon"
      spawn-at-startup "sh" "-c" "bash ~/.config/swww/wallpaper.sh ~/onedrive/Wallpapers/"
    '';
  };
}
