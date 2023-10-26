{ config, lib, ... }:
with lib;

let
  cnfg = config.home.components.git;
in
{
  options.home.components.gitui.enable = mkEnableOption "git";

  config = mkIf cnfg.enable {
    programs = {
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
