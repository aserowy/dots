{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.swappy;
in
{
  options.home.components.swappy.enable = mkEnableOption "swappy";

  config = mkIf cnfg.enable {
    home = {
      file.".config/swappy/config" = {
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

      packages = with pkgs; [
        swappy
      ];
    };
  };
}
