final: prev:
let
  inherit (prev.lib) mapAttrs removePrefix;

  imported = import ./_sources/generated.nix { inherit (final) fetchurl fetchgit; };

  sources = mapAttrs
    (pname: meta: meta // { version = removePrefix "v" meta.version; })
    imported;
in
{
  edge = final.callPackage ./edge {
    inherit sources;
    gconf = final.gnome2.GConf;
  };

  widevine-cdm = final.callPackage ./widevine-cdm { };
}
