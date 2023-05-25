{ stdenv, fetchurl, unzip }:
let
  buildVscodeExtension =
    a@{ name
    , src
    , vscodeExtUniqueId
    , configurePhase ? ''
        runHook preConfigure
        runHook postConfigure
      ''
    , buildPhase ? ''
        runHook preBuild
        runHook postBuild
      ''
    , dontPatchELF ? true
    , dontStrip ? true
    , buildInputs ? [ ]
    , ...
    }:
    stdenv.mkDerivation ((removeAttrs a [ "vscodeExtUniqueId" ]) // {
      name = "vscode-extension-${name}";

      inherit vscodeExtUniqueId;
      inherit configurePhase buildPhase dontPatchELF dontStrip;

      installPrefix = "share/vscode/extensions/${vscodeExtUniqueId}";

      buildInputs = [ unzip ] ++ buildInputs;

      unpackPhase = ''
        runHook preUnpack

        cp $src ${vscodeExtUniqueId}.zip
        unzip ${vscodeExtUniqueId}.zip
        rm ${vscodeExtUniqueId}.zip

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/$installPrefix"
        mv extension.vsixmanifest "$out/$installPrefix/.vsixmanifest"

        cd extension
        find . -mindepth 1 -maxdepth 1 | xargs -d'\n' mv -t "$out/$installPrefix/"

        runHook postInstall
      '';
    });

  buildVscodeMarketplaceExtension =
    a@{ name ? ""
    , mktplcRef
    , ...
    }: assert "" == name;
    buildVscodeExtension ((removeAttrs a [ "mktplcRef" "vsix" ]) // {
      name = "${mktplcRef.publisher}-${mktplcRef.name}-${mktplcRef.version}";
      src = mktplcRef.src;
      version = mktplcRef.version;
      vscodeExtUniqueId = "${mktplcRef.publisher}.${mktplcRef.name}-${mktplcRef.version}";
      vscodeExtPublisher = mktplcRef.publisher;
    });

  mktplcRefAttrList = [
    "name"
    "publisher"
    "src"
    "version"
  ];

  extensionFromVscodeMarketplace = ext:
    buildVscodeMarketplaceExtension ((removeAttrs ext mktplcRefAttrList) // {
      mktplcRef = ext;
    });
in
{
  inherit buildVscodeExtension buildVscodeMarketplaceExtension extensionFromVscodeMarketplace;
}
