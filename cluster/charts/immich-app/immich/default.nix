let
  commonSchemaVersion = "5.1.0";
in
{
  repo = "oci://ghcr.io/immich-app/immich-charts";
  chart = "immich";
  version = "0.13.2";
  chartHash = "sha256-SvZBu1vaKYoG9yGd0qHCNDfT69cUm4PX75M8ZfLJOfg=";

  vendoredCommonSchema = {
    remoteBaseUrl = "https://raw.githubusercontent.com/bjw-s-labs/helm-charts/common-${commonSchemaVersion}/charts/library/common";
    source = {
      owner = "bjw-s-labs";
      repo = "helm-charts";
      rev = "common-${commonSchemaVersion}";
      hash = "sha256-/CdOju2G0FIdwspD3+jFsXyy+UVVE72fH/m4fYTzQRw=";
    };
  };
}
