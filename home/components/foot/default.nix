{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.foot;
in
{
  options.home.components.foot = {
    enable = mkEnableOption "foot";

    enableAsHyprlandDefaultTerminal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, foot gets set as default terminal in Hyprland.
      '';
    };

    setDpiAware = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, foot will be set to be DPI aware.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          dpi-aware = mkIf cnfg.setDpiAware "yes";
          font = "JetBrainsMonoNerdFont:size=10";
        };
        colors = {
          background = "282c34";
          foreground = "b9c0cb";
          # Normal/regular colors (color palette 0-7)
          regular0 = "41444d # black";
          regular1 = "fc2f52  # red";
          regular2 = "25a45c  # green";
          regular3 = "ffcc00  # yellow";
          regular4 = "3476ff  # blue";
          regular5 = "7a82da  # magenta";
          regular6 = "4483aa  # cyan";
          regular7 = "cdd4e0  # white";
          # Bright colors (color palette 8-15)
          bright0 = "8f9aae   # bright black";
          bright1 = "ff6480   # bright red";
          bright2 = "3fc56b   # bright green";
          bright3 = "f9c859   # bright yellow";
          bright4 = "10b1fe   # bright blue";
          bright5 = "ff78f8   # bright magenta";
          bright6 = "5fb9bc   # bright cyan";
          bright7 = "ffffff   # bright white";
        };
      };
    };

    home.modules.hyprland = mkIf cnfg.enableAsHyprlandDefaultTerminal {
      defaultTerminal = "foot";
      tuiLaunchCommand = "foot [PROG]";
    };
  };
}
