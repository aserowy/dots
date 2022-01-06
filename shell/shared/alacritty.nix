{ config, pkgs, lib, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      alacritty
    ];

    etc."alacritty.yaml" = {
      text = ''
        colors:
          bright:
            black: '#5c6370'
            blue: '#61afef'
            cyan: '#56b6c2'
            green: '#98c379'
            magenta: '#c678dd'
            red: '#e06c75'
            white: '#abb2bf'
            yellow: '#e5c07b'
          cursor:
            cursor: '#abb2bf'
            text: '#828997'
          normal:
            black: '#3e4451'
            blue: '#61afef'
            cyan: '#56b6c2'
            green: '#98c379'
            magenta: '#c678dd'
            red: '#e06c75'
            white: '#abb2bf'
            yellow: '#e5c07b'
          primary:
            background: '#23272e'
            forground: '#abb2bf'
          selection:
            background: '#3e4451'
            text: '#abb2bf'
        cursor:
          style: 
            shape: 'Block'
            blinking: off
        font:
          normal:
            family: 'FiraCode Nerd Font Mono'
            style: Regular
          size: 10
      '';
    };
  };
}
