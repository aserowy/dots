{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome

    (pkgs.writeShellScriptBin "teams" ''
      ${google-chrome}/bin/google-chrome-stable \
        --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
        --ozone-platform=wayland \
        --new-window \
        --app=https://teams.microsoft.com 
    '')
  ];
}
