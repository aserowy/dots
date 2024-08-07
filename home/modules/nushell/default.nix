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
        yeet
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
          y = "yeet";

          gad = "git add";
          gada = "git add --all";
          gbr = "git branch";
          gbrclean = "bash -c \"git fetch --prune && git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D\"";
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
