{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "outlook" ''
      ${edge}/bin/microsoft-edge-beta \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        --enable-features=WebRTCPipeWireCapturer \
        --app=https://www.outlook.com \
        --new-window
    '')
  ];

  imports = [
    ../programs/edge.nix
  ];
}
