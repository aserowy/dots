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
          alacritty = {
            enable = true;
          };

          fuzzel = {
            enable = true;
          };
        };

        file = {
          ".config/niri/config.kdl".source = builtins.toFile "niri-config" ''
            ${cnfg.prependedConfig}

            ${niriConfig}
          '';
        };

        modules = {
          gaming.enableXwaylandSatellite = true;

          browser.enable = true;
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

        sessionVariables = {
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
        };
      };
    };
}
