{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "teams" ''
      ${microsoft-edge}/bin/microsoft-edge \
        --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
        --ozone-platform=wayland \
        --new-window \
        --app=https://teams.microsoft.com 
    '')
  ];
}
