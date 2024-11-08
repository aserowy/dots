{ nixidy, pkgs }: with pkgs; mkShell
{
  buildInputs = [
    doas-sudo-shim
    kubectl
    nil
    nixidy.packages.${pkgs.system}.default
    nixpkgs-fmt
    nodejs_20
    nodePackages.prettier
    nodePackages.vscode-json-languageserver
    nufmt
    sops
    stylua
    sumneko-lua-language-server
    taplo
  ];
}

# a14y

#   packages = {
# nixidy = nixidy.packages.${system}.default;
# generators = {
# cilium = nixidy.packages.${system}.generators.fromCRD {
# name = "cilium";
# src = pkgs.fetchFromGitHub {
# owner = "cilium";
# repo = "cilium";
# rev = "v1.16.0";
# hash = "sha256-LJrNGHF52hdKCuVwjvGifqsH+8hxkf/A3LZNpCHeR7E=";
# };
# crds = [
# "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumnetworkpolicies.yaml"
# "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumclusterwidenetworkpolicies.yaml"
# ];
# };
#
#
# echo "generate cilium"
# cat ${self.packages.${system}.generators.cilium} > modules/cilium/generated.nix
