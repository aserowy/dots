{ config, lib, ... }:
with lib;

let
  cnfg = config.home.modules.grimshot;
in
{
  options.home.modules.grimshot.enable = mkEnableOption "grimshot";

  config = mkIf cnfg.enable {
    home.file.".config/swappy/config" = {
      text = ''
        [Default]
        save_dir=$HOME/pictures
        save_filename_format=screenshot-%Y%m%d-%H%M%S.png
        show_panel=false
        line_size=5
        text_size=20
        text_font=sans-serif
      '';
    };
  };
}
