{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.niri;
in
{
  options.home.modules.niri = {
    enable = mkEnableOption "niri";

    prependedConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to niri config.
      '';
    };
  };

  config =
    let
      niriConfig = builtins.readFile ./config.kdl;
    in
    mkIf cnfg.enable {
      home = {
        components = {
          brave = {
            enable = true;
            enableXdgAssociations = true;
            setDefaultBrowserSessionVariable = true;
          };

          fuzzel.enable = true;
          ghostty.enable = true;
          wpaperd.enable = true;
        };

        file = {
          ".config/niri/config.kdl".source = builtins.toFile "niri-config" ''
            ${cnfg.prependedConfig}

            ${niriConfig}
          '';

          ".config/niri/scripts".source = ./scripts;
        };

        modules = {
          clipboard.enable = true;
          statusbar.enable = true;
        };

        packages = with pkgs; [
          niri

          (pkgs.writeShellScriptBin "outputshot" ''
            niri msg action screenshot-screen
          '')
          (pkgs.writeShellScriptBin "screenshot" ''
            niri msg action screenshot
          '')
          (pkgs.writeShellScriptBin "windowshot" ''
            niri msg action screenshot-window
          '')
        ];
      };

      gtk.theme = {
        name = "Fluent-Dark-compact";
        package = pkgs.fluent-gtk-theme;
      };
    };
}
