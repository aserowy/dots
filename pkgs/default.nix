final: prev:
let
  inherit (final.lib) mapAttrs removePrefix;

  # import nvfetcher sources
  imported = import ./_sources/generated.nix { inherit (final) fetchurl fetchgit; };

  fetches = mapAttrs
    (pname: meta: meta // { version = removePrefix "v" meta.version; })
    imported;
in
{
  edge = final.callPackage ./edge {
    gconf = final.gnome2.GConf;
    sources = fetches;
  };

  eww = final.callPackage ./eww {
    inherit fetches;
    makeRustPlatform = (final.pkgs.makeRustPlatform {
      inherit (final.fenix.latest) cargo rustc;
    });
  };

  #vscode-extensions = channels.latest.vscode-extensions // (packageSets "vscode-extensions");

  widevine-cdm = final.callPackage ./widevine-cdm {
   sources = fetches;
  };
}
