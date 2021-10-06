final: prev:
let
  sources = (import ./_sources/generated.nix) { inherit (final) fetchurl fetchgit; };
in
{
  edge = final.callPackage ./edge { gconf = final.gnome2.GConf; };
}
