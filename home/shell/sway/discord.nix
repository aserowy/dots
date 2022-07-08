{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "discord" ''
      ${microsoft-edge}/bin/microsoft-edge \
        --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
        --ozone-platform=wayland \
        --new-window \
        --app=https://discord.com/app
    '')
  ];
}
