{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.uv;

  quoted = map (tool: "\"${tool}\"") cnfg.tools;
  toolList = builtins.concatStringsSep " " quoted;

  configure = pkgs.writeText "configure-uv.sh" ''
    #!/bin/sh

    echo "🔧 Checking uv tools..."
    mkdir -p "$HOME/.local/bin"

    if [ -f "$HOME/.nix-profile/bin/uv" ]; then
      for tool in ${toolList}; do
        # Check if tool is already installed and working
        if ! "$HOME/.nix-profile/bin/uv" tool list 2>/dev/null | grep -q "^$tool "; then
          echo "📦 Installing $tool..."
          "$HOME/.nix-profile/bin/uv" tool install "$tool"
        else
          echo "✅ $tool already installed, skipping"
        fi
      done
      echo "✅ uv tools check complete"
    else
      echo "❌ uv not found at $HOME/.nix-profile/bin/uv, skipping uv tool installs"
    fi
  '';

in
{
  options.home.components.uv = {
    enable = mkEnableOption "uv";

    tools = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra tools to be installed in uv.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs.uv.enable = true;

    # NOTE: https://github.com/ishandhanani/dotfiles/blob/main/home-manager/modules/uvx.nix
    home.activation.installUvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.bash}/bin/sh ${configure}
    '';
  };
}
