final: prev:
let
  inherit (final.lib) filterAttrs hasPrefix mapAttrs mapAttrs' nameValuePair removePrefix;

  helper = import ./vscode-extensions.nix { inherit (final) stdenv fetchurl unzip; };

  # import nvfetcher sources
  imported = import ./_sources/generated.nix { inherit (final) fetchurl fetchgit; };

  fetches = mapAttrs
    (pname: meta: meta // { version = removePrefix "v" meta.version; })
    imported;

  # set package sets for extensions
  packageSets = packageSet:
    let
      prefix = "${packageSet}-";

      packageBuilder = {
        "vscode-extensions" = helper.extensionFromVscodeMarketplace;
      }.${packageSet};

      packages = mapAttrs'
        (name: value: nameValuePair (removePrefix prefix name) (value))
        (filterAttrs (name: value: hasPrefix prefix name) fetches);
    in
    mapAttrs
      (n: v: packageBuilder {
        inherit (v) name publisher src version;
      })
      packages;
in
{
  sources = final.callPackage (import ./_sources/generated.nix) { };

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

  vscode-extensions = (packageSets "vscode-extensions");

  widevine-cdm = final.callPackage ./widevine-cdm {
    sources = fetches;
  };
}
