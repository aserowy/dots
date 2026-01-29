{
  lib,
  nixidy,
  nixhelm,
  pkgs,
}:
let
  generators = {
    akri = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromCRD {
      name = "akri";
      src = nixhelm.chartsDerivations.${pkgs.stdenv.hostPlatform.system}.project-akri.akri;
      crds = [
        "crds/akri-configuration-crd.yaml"
        "crds/akri-instance-crd.yaml"
      ];
    };
    cert-manager = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromCRD {
      name = "cert-manager";
      src = pkgs.fetchFromGitHub {
        owner = "cert-manager";
        repo = "cert-manager";
        rev = "v1.19.2";
        hash = "sha256-0m8+J8rECY7+BXTkSAaDUBsz4gJJO7fMMbGscLoKGUA=";
      };
      crds = [
        "deploy/crds/cert-manager.io_certificates.yaml"
        "deploy/crds/cert-manager.io_clusterissuers.yaml"
      ];
    };
    cilium = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromCRD {
      name = "cilium";
      src = pkgs.fetchFromGitHub {
        owner = "cilium";
        repo = "cilium";
        rev = "v1.18.6";
        hash = "sha256-V4CbizefPn8VnZnnSxgQP2eq72wNVD0niuEmAlr28Xs=";
      };
      crds = [
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumnetworkpolicies.yaml"
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumclusterwidenetworkpolicies.yaml"
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumloadbalancerippools.yaml"
      ];
    };
    sops = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromCRD {
      name = "sops";
      src = nixhelm.chartsDerivations.${pkgs.stdenv.hostPlatform.system}.isindir.sops-secrets-operator;
      crds = [ "crds/isindir.github.com_sopssecrets.yaml" ];
    };
  };
in
pkgs.mkShell {
  packages = [
    # pkgs.azure-cli
    # pkgs.kubectl
    # pkgs.renovate

    pkgs.marksman
    pkgs.nixd
    nixidy.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.nixfmt
    pkgs.nodejs_24
    pkgs.nodePackages.prettier
    pkgs.nodePackages.vscode-json-languageserver
    pkgs.nufmt
    pkgs.sops
    pkgs.stylua
    pkgs.lua-language-server
    pkgs.taplo
  ]
  ++ lib.optionals (!pkgs.pkgs.stdenv.isDarwin) [
    pkgs.doas-sudo-shim
  ];

  shellHook = ''
    echo "generate akri crds"
    cat ${generators.akri} > ./cluster/crd/akri.nix
    echo "generate cert-manager"
    cat ${generators.cert-manager} > ./cluster/crd/cert-manager.nix
    echo "generate cilium"
    cat ${generators.cilium} > ./cluster/crd/cilium.nix
    echo "generate sops"
    cat ${generators.sops} > ./cluster/crd/sops.nix
  '';
}
