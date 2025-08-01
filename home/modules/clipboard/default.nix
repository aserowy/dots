{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.clipboard;
in
{
  options.home.modules.clipboard = {
    enable = mkEnableOption "clipboard";

    enableNiriIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, init clipman with wl-clipboard tools in niri.
      '';
    };
  };

  config = mkIf cnfg.enable {
    home = {
      file.".config/clipman/open_history.nu".source = ./open_history.nu;

      components.fuzzel.enable = true;

      packages = with pkgs; [
        clipman
        wl-clipboard
      ];
    };

    home.modules.niri.prependedConfig = mkIf cnfg.enableNiriIntegration ''
      spawn-at-startup "wl-paste" "-t" "text" "--watch" "clipman" "store" "--no-persist"
    '';
  };
}
