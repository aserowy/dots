{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    playerctl

    (spotify-spicetified.override {
      theme = "Dribbblish";

      # FIX: currently only in own fork (pr into upstream)
      colorScheme = "onedark";

      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      customExtensions = {
        "dribbblish.js" = "${spicetify-themes}/Dribbblish/dribbblish.js";
      };
      enabledCustomApps = [
        "lyrics-plus"
        "new-releases"
        "reddit"
      ];
      enabledExtensions = [
        "dribbblish.js"
        "fullAppDisplay.js"
        "loopyLoop.js"
        "popupLyrics.js"
        "shuffle+.js"
        "trashbin.js"
      ];
      extraConfig = ''
        [Patch]
        xpui.js_find_8008 = ,(\w+=)32,
        xpui.js_repl_8008 = ,''${1}56,
      '';
    })
  ];
}
