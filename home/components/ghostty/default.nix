{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.ghostty;
in
{
  options.home.components.ghostty = {
    enable = mkEnableOption "ghostty";

    theme = mkOption {
      type = types.nullOr types.str;
      default = "Bluloco Dark";
      description = "The theme setting for ghostty.";
    };
  };

  config =
    let
      ghosttyConfig = builtins.readFile ./ghostty.config;

      themeSetting = if cnfg.theme == null then "" else "theme = ${cnfg.theme}";
    in
    mkIf cnfg.enable {
      home = {
        file = {
          ".config/ghostty/config".source = builtins.toFile "ghostty-config" ''
            ${ghosttyConfig}
            ${themeSetting}
          '';
        };

        packages = with pkgs; [
          ghostty
        ];
      };
    };
}
