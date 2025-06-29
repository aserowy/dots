{
  lib,
  nixidy,
  nixhelm,
  pkgs,
}:
let
  generators = {
    akri = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "akri";
      src = nixhelm.chartsDerivations.${pkgs.system}.project-akri.akri;
      crds = [
        "crds/akri-configuration-crd.yaml"
        "crds/akri-instance-crd.yaml"
      ];
    };
    cert-manager = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "cert-manager";
      src = pkgs.fetchFromGitHub {
        owner = "cert-manager";
        repo = "cert-manager";
        rev = "v1.18.1";
        hash = "sha256-X2FWGW3085KKzXOce8j46xiPBjfH+K4clqrpQFpfWPA=";
      };
      crds = [
        "deploy/crds/crd-certificates.yaml"
        "deploy/crds/crd-issuers.yaml"
      ];
    };
    cilium = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "cilium";
      src = pkgs.fetchFromGitHub {
        owner = "cilium";
        repo = "cilium";
        rev = "v1.17.5";
        hash = "sha256-frpu1kJICbZFwmH/KQ2pZHcS2M+XvLvxZpzVxok2eM8=";
      };
      crds = [
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumnetworkpolicies.yaml"
        "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumclusterwidenetworkpolicies.yaml"
        "pkg/k8s/apis/cilium.io/client/crds/v2alpha1/ciliumloadbalancerippools.yaml"
      ];
    };
    sops = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "sops";
      src = nixhelm.chartsDerivations.${pkgs.system}.isindir.sops-secrets-operator;
      crds = [ "crds/isindir.github.com_sopssecrets.yaml" ];
    };
    traefik = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "traefik";
      src = nixhelm.chartsDerivations.${pkgs.system}.traefik.traefik;
      crds = [
        "crds/traefik.io_ingressroutes.yaml"
      ];
    };
  };
in
pkgs.mkShell {
  packages =
    [
      pkgs.azure-cli
      pkgs.kubectl
      pkgs.marksman
      pkgs.nixd
      nixidy.packages.${pkgs.system}.default
      pkgs.nixfmt-rfc-style
      pkgs.nodejs_20
      pkgs.nodePackages.prettier
      pkgs.nodePackages.vscode-json-languageserver
      pkgs.nufmt
      pkgs.renovate
      pkgs.sops
      pkgs.stylua
      pkgs.sumneko-lua-language-server
      pkgs.taplo
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
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
    echo "generate traefik"
    cat ${generators.traefik} > ./cluster/crd/traefik.nix
  '';
}
