{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.noctalia;
in
{
  options.home.modules.noctalia = {
    enable = mkEnableOption "noctalia";

    prependedConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra commands that are prepended to noctalias niri config.
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

          ghostty.enable = true;
        };

        file = {
          ".config/niri/config.kdl".source = builtins.toFile "niri-config" ''
            ${cnfg.prependedConfig}

            ${niriConfig}
          '';
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

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;
      };
    };
}
