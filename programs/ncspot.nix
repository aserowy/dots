{ config, pkgs, ... }:
{
  programs.ncspot = {
    enable = true;
    settings = {
      gapless = true;
      notify = true;
      # BUG: https://github.com/hrkfdn/ncspot/issues/114
      theme = {
        background = "background";
        cmdline = "background";
        cmdline_bg = "foreground";
        #cmdline_bg = "#23272E";
        error = "red";
        error_bg = "background";
        #error_bg = "#23272E";
        highlight = "foreground";
        highlight_bg = "black";
        playing = "yellow";
        playing_bg = "background";
        playing_selected = "yellow";
        primary = "foreground";
        secondary = "background";
        statusbar = "yellow";
        statusbar_bg = "background";
        #statusbar_bg = "#23272E";
        statusbar_progress = "blue";
        title = "red";
      };
      use_nerdfont = true;
    };
  };
}
