{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.modules.aiagents;
in
{
  options.home.modules.aiagents.enable = mkEnableOption "aiagents";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        openspec
        claude-code
      ];

      sessionVariables = {
        OPENSPEC_TELEMETRY = 0;
      };

      components = {
        opencode.enable = true;

        uv = {
          # enable = true;
          tools = [
            # "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
          ];
        };
      };
    };
  };
}
