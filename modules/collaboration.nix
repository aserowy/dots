{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome

    (pkgs.writeShellScriptBin "discord" ''
      ${edge}/bin/microsoft-edge-beta \
        --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
        --ozone-platform=wayland \
        --app=https://www.discord.app \
        --new-window
    '')

    (pkgs.writeShellScriptBin "teams" ''
      ${google-chrome}/bin/google-chrome-stable \
        --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
        --ozone-platform=wayland \
        --new-window \
        --app=https://teams.microsoft.com 
    '')

    (pkgs.writeShellScriptBin "whatsapp" ''
      ${edge}/bin/microsoft-edge-beta \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        --enable-features=WebRTCPipeWireCapturer \
        --app=https://web.whatsapp.com \
        --new-window
    '')
  ];
}
