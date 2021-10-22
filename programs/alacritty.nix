{ config, pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "#23272e";
          forground = "#abb2bf";
        };
        cursor = {
          cursor = "#ABB2BF";
          text = "#828997";
        };
        selection = {
          background = "#3E4451";
          text = "#ABB2BF";
        };
        normal = {
          black = "#3E4451";
          red = "#e06c75";
          green = "#98c379";
          yellow = "#e5c07b";
          blue = "#61afef";
          magenta = "#c678dd";
          cyan = "#56b6c2";
          white = "#ABB2BF";
        };
        bright = {
          black = "#5C6370";
          red = "#e06c75";
          green = "#98c379";
          yellow = "#e5c07b";
          blue = "#61afef";
          magenta = "#c678dd";
          cyan = "#56b6c2";
          white = "#ABB2BF";
        };
      };
      cursor = {
        style = "Block";
      };
      font = {
        family = "FiraCode Nerd Font Mono";
        size = "12";
      };
    };
  };
}
