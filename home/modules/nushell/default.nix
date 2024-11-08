{
  config,
  lib,
  pkgs,
  ...
}:
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
        broot
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
        environmentVariables = builtins.mapAttrs (
          name: value: "${builtins.toString value}"
        ) config.home.sessionVariables;

        shellAliases = {
          cat = "bat";
          y = "yeet";

          gad = "git add";
          gada = "git add --all";
          gbr = "git branch";
          gbrcl = "bash -c \"git fetch --prune && git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D\"";
          gbrd = "git branch -D";
          gcl = "git clone --recurse-submodules -j8";
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
          gsw = "git switch";
          gswc = "git switch -c";
          gwta = "git worktree add -fb";
          gwtls = "git worktree list -v";
          gwtrm = "git worktree remove";
          gta = "git tag";
          gtam = "git tag -a -m";

          ll = "ls -l";
          lla = "ls -la";

          zls = "zellij ls";
          zs = "zellij --session";
          za = "zellij attach";
          zd = "zellij delete-session";
          zda = "zellij delete-all-sessions";
          zk = "zellij kill-session";
          zka = "zellij kill-all-sessions";
        };
      };
    };
  };
}
