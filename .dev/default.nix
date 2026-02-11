{
  lib,
  nixidy,
  pkgs,
  charts,
}:
let
  generators = {
    akri = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromChartCRD {
      name = "akri";
      chart = charts.project-akri.akri;
    };
    cert-manager = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromChartCRD {
      name = "cert-manager";
      chart = charts.jetstack.cert-manager;
      values = {
        crds.enabled = true;
      };
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
    cloudnative-pg = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromChartCRD {
      name = "cloudnative-pg";
      chart = charts.cloudnative-pg.cloudnative-pg;
    };
    sops = nixidy.packages.${pkgs.stdenv.hostPlatform.system}.generators.fromChartCRD {
      name = "sops";
      chart = charts.isindir.sops-secrets-operator;
    };
  };
in
pkgs.mkShell {
  packages = [
    nixidy.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.doas-sudo-shim
    pkgs.kubernetes-helm
    pkgs.lua-language-server
    pkgs.marksman
    pkgs.nixd
    pkgs.nixfmt
    pkgs.nodePackages.prettier
    pkgs.nodePackages.vscode-json-languageserver
    pkgs.nodejs_24
    pkgs.nufmt
    pkgs.renovate
    pkgs.sops
    pkgs.stylua
    pkgs.taplo
  ];

  shellHook = ''
    echo "generate akri crds"
    cat ${generators.akri} > ./cluster/crd/akri.nix
    echo "generate cert-manager crds"
    cat ${generators.cert-manager} > ./cluster/crd/cert-manager.nix
    echo "generate cilium crds"
    cat ${generators.cilium} > ./cluster/crd/cilium.nix
    echo "generate cloudnative-pg crds"
    cat ${generators.cloudnative-pg} > ./cluster/crd/cloudnative-pg.nix
    echo "generate sops crds"
    cat ${generators.sops} > ./cluster/crd/sops.nix
  '';
}
