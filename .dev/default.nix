{
  lib,
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
pkgs.mkShell {
  packages =
    [
      pkgs.kubectl
      pkgs.marksman
      pkgs.nixd
      nixidy.packages.${pkgs.system}.default
      pkgs.nixfmt-rfc-style
      pkgs.nodejs_20
      pkgs.nodePackages.prettier
      pkgs.nodePackages.vscode-json-languageserver
      pkgs.nufmt
      pkgs.sops
      pkgs.stylua
      pkgs.sumneko-lua-language-server
      pkgs.taplo
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      pkgs.doas-sudo-shim
    ];

  shellHook = ''
    echo "generate cilium"
    cat ${generators.cilium} > ./cluster/crd/cilium.nix
  '';
}
