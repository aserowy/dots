{
  lib,
  nixidy,
  nixhelm,
  pkgs,
}:
let
  generators = {
    cilium = nixidy.packages.${pkgs.system}.generators.fromCRD {
      name = "cilium";
      src = pkgs.fetchFromGitHub {
        owner = "cilium";
        repo = "cilium";
        rev = "v1.17.4";
        hash = "sha256-v6tNi85OxWFDWJTpWGxi+ywOHxu3g8VLaxdAdb1c/ho=";
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
    echo "generate sops"
    cat ${generators.sops} > ./cluster/crd/sops.nix
    echo "generate traefik"
    cat ${generators.traefik} > ./cluster/crd/traefik.nix
  '';
}
