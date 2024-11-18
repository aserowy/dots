{
  nixidy,
  pkgs,
}:
let
  generators = {
    cilium = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "cilium";
      src = pkgs.fetchFromGitHub {
        owner = "cilium";
        repo = "cilium";
        rev = "v1.16.0";
        hash = "sha256-LJrNGHF52hdKCuVwjvGifqsH+8hxkf/A3LZNpCHeR7E=";
      };
      crds = [
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumnetworkpolicies.yaml"
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumclusterwidenetworkpolicies.yaml"
      ];
    };
  };
in
with pkgs;
mkShell {
  packages = [
    doas-sudo-shim
    kubectl
        marksman
    nixd
    nixidy.packages.${pkgs.system}.default
    nixfmt-rfc-style
    nodejs_20
    nodePackages.prettier
    nodePackages.vscode-json-languageserver
    nufmt
    sops
    stylua
    sumneko-lua-language-server
    taplo
  ];

  shellHook = ''
    echo "generate cilium"
    cat ${generators.cilium} > ./cluster/crd/cilium.nix
  '';
}
