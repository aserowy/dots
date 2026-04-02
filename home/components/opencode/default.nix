{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.opencode;
in
{
  options.home.components.opencode.enable = mkEnableOption "opencode";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        opencode
        openspec
      ];

      file = {
        ".config/opencode/opencode.json".source = ./opencode.json;
      };

      components.uv = {
        enable = true;
        tools = [
          # "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
        ];
      };
    };
  };
}
