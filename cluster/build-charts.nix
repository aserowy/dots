{
  haumea,
  nix-kube-generators,
}:
{ pkgs }:
let
  kubernetesGeneratorLibrary = nix-kube-generators.lib { inherit pkgs; };

  vendorCommonSchema =
    downloadedChart: vendoredCommonSchema:
    let
      commonSchemaSource = pkgs.fetchFromGitHub vendoredCommonSchema.source;
      remoteSchemaDirectory = vendoredCommonSchema.remoteBaseUrl;
    in
    pkgs.runCommand "${downloadedChart.name}-with-local-schema" { } ''
      cp -R ${downloadedChart}/. "$out"
      chmod -R u+w "$out"

      # The packaged common chart excludes its supporting schemas. Restore the
      # complete, pinned schema tree so Helm can validate without network access.
      mkdir -p "$out/charts/common/schemas"
      cp -R ${commonSchemaSource}/charts/library/common/schemas/. "$out/charts/common/schemas/"
      cp ${commonSchemaSource}/charts/library/common/values.schema.json \
        "$out/charts/common/values.schema.json"

      # Preserve each schema's base URI semantics while redirecting references
      # from GitHub to the immutable patched chart in the Nix store.
      substituteInPlace "$out/charts/common"/*.json "$out/charts/common/schemas"/*.json \
        --replace \
        '${remoteSchemaDirectory}' \
        "file://$out/charts/common"

      substituteInPlace "$out/values.schema.json" \
        --replace-fail \
        '${remoteSchemaDirectory}/values.schema.json' \
        "file://$out/charts/common/values.schema.json"
    '';

  loadChart =
    { ... }:
    chartDefinitionPath:
    let
      chartDefinition = import chartDefinitionPath;
      helmDownloadArguments = builtins.removeAttrs chartDefinition [ "vendoredCommonSchema" ];
      downloadedChart = kubernetesGeneratorLibrary.downloadHelmChart helmDownloadArguments;
    in
    if chartDefinition ? vendoredCommonSchema then
      vendorCommonSchema downloadedChart chartDefinition.vendoredCommonSchema
    else
      downloadedChart;
in
haumea.lib.load {
  src = ./charts;
  loader = loadChart;
  transformer = haumea.lib.transformers.liftDefault;
}
