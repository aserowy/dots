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

  # TODO: seperate gitui in own component
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

      gitui = {
        enable = true;
        keyConfig = ''
          move_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
          move_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
          move_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
          move_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),

          stash_open: Some(( code: Char('l'), modifiers: ( bits: 0,),)),

          open_help: Some(( code: Char('?'), modifiers: ( bits: 0,),)),
        '';
      };
    };
  };
}
