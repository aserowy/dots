{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.git;
in
{
  options.home.components.git = {
    enable = mkEnableOption "git";

    editor = mkOption {
      type = types.str;
      default = "nvim";
      description = ''
        Sets the core.editor property.
      '';
    };
  };

  config = mkIf cnfg.enable {
    programs = {
      git = {
        enable = true;
        userName = "aserowy";
        userEmail = "serowy@hotmail.com";
        extraConfig = {
          core.editor = cnfg.editor;
          credential.useHttpPath = "true";
          init.defaultBranch = "main";
          push.autoSetupRemote = "true";
        };
        lfs = {
          enable = true;
        };
      };
    };
  };
}
