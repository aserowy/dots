{ config, lib, pkgs, ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/Users/alexander.serowy";
    username = "alexander.serowy";

    components = {
      docker.enable = true;
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

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    ssh.matchBlocks = { };
  };
}
