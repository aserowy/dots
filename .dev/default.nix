{
  self,
  nixidy,
  pkgs,
}:
with pkgs;
mkShell {
  packages = [
    doas-sudo-shim
    kubectl
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
    cat ${self.packages.${pkgs.system}.generators.cilium} > ./cluster/cdr/cilium.nix
  '';
}
