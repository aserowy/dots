{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.nushell;
in
{
  options.home.modules.nushell.enable = mkEnableOption "nushell";

  config = mkIf cnfg.enable {
    home = {
      components = {
        direnv.enable = true;
        starship.enable = true;
      };

      packages = with pkgs; [
        carapace
        zoxide
      ];
    };

    programs = {
      direnv.enableNushellIntegration = false;

      nushell = {
        enable = true;
        configFile.source = ./nushell-config.nu;
        envFile.source = ./nushell-env.nu;

        # FIX: https://github.com/nix-community/home-manager/issues/4313
        environmentVariables =
          builtins.mapAttrs
            (name: value: "\"${builtins.toString value}\"")
            config.home.sessionVariables;

        shellAliases = {
          cat = "bat";

          gad = "git add";
          gada = "git add --all";
          gbr = "git branch";
          gcl = "git clone --recurse-submodules -j8";
          gco = "git checkout";
          gcm = "git commit -s -m";
          gcma = "git commit --all -s -m";
          gcmam = "git commit --amend";
          gdf = "git diff";
          gfe = "git fetch";
          gfea = "git fetch --all";
          gmg = "git merge";
          gpl = "git pull --autostash --rebase";
          gpu = "git push";
          gput = "git push --tags";
          grs = "git reset";
          grsh = "git reset --hard";
          gst = "git status";
          gta = "git tag";
          gtam = "git tag -a -m";

          ll = "ls -l";
          lla = "ls -la";
        };
      };
    };
  };
}
