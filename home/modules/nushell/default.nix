{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.nushell;
in
{
  options.home.nushell.enable = mkEnableOption "nushell";

  config = mkIf cnfg.enable {
    home = {
      packages = with pkgs; [
        carapace
      ];

      file.".config/starship.toml".source = ./starship.toml;
    };

    programs = {
      direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
      };

      nushell = {
        enable = true;
        configFile.source = ./nushell-config.nu;
        envFile.source = ./nushell-env.nu;
        shellAliases = {
          cat = "bat";

          gad = "git add";
          gada = "git add --all";
          gbr = "git branch";
          gcl = "git clone --recurse-submodules -j8";
          gco = "git checkout";
          gcm = "git commit -s -m";
          gdf = "git diff";
          gfe = "git fetch";
          gfea = "git fetch --all";
          gmg = "git merge";
          gpl = "git pull --autostash --rebase";
          gpu = "git push";
          gput = "git push --tags";
          grs = "git reset";
          gst = "git status";
          gta = "git tag";
          gtam = "git tag -a -m";

          ll = "ls -l";
          lla = "ls -la";
        };
      };

      starship = {
        enable = true;
      };

      zoxide = {
        enable = true;
      };
    };
  };
}
