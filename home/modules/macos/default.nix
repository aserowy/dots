{ config, pkgs, lib, ... }:
{
  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      nerdfonts
    ];

    activation.trampolineApps =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        toDir="$HOME/Applications/Home Manager Trampolines"
        fromDir="${apps}/Applications"
        rm -rf "$toDir"
        mkdir "$toDir"
        (
          cd "$fromDir"
          for app in *.app; do
            /usr/bin/osacompile -o "$toDir/$app" -e "do shell script \"open '$fromDir/$app'\""
            icon="$(/usr/bin/plutil -extract CFBundleIconFile raw "$fromDir/$app/Contents/Info.plist")"
            mkdir -p "$toDir/$app/Contents/Resources"
            cp -f "$fromDir/$app/Contents/Resources/$icon" "$toDir/$app/Contents/Resources/applet.icns"
          done
        )
      '';
  };

  imports = [
    ../shared/obsidian.nix
    ../shared/vscode.nix
  ];
}
