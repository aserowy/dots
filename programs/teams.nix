{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # BUG: inprivate and app mode will not open anything
    # --app=https://teams.microsoft.com 
    (pkgs.writeShellScriptBin "teams" ''
      ${edge}/bin/microsoft-edge-beta \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        --enable-features=WebRTCPipeWireCapturer \
        --new-window \
        --inprivate \
        https://teams.microsoft.com
    '')
  ];
}
