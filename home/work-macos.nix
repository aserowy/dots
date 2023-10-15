{ config, lib, pkgs, ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ./base.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    modules = {
      docker.enable = true;
      vscode.enable = true;
    };

    packages = with pkgs; [
      nerdfonts
      obsidian
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

  programs = {
    ssh.matchBlocks = { };
  };
}
