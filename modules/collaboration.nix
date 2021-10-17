{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "discord" ''
      ${edge}/bin/microsoft-edge-beta \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        --enable-features=WebRTCPipeWireCapturer \
        --app=https://www.discord.app \
        --new-window
    '')

    (pkgs.writeShellScriptBin "teams" ''
      ${edge}/bin/microsoft-edge-beta \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        --enable-features=WebRTCPipeWireCapturer \
        --new-window \
        --inprivate \
        https://teams.microsoft.com
        # BUG: inprivate and app mode will not open anything
        # --app=https://teams.microsoft.com 
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
